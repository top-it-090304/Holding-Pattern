extends Sprite2D

var current_route: Dictionary
var t: float = 0.0         
var target_speed: float = 90.0
var current_speed: float = 0.0  
var forward: bool = true
var color: String
var is_big: bool = true

var cargo: Array = []
var max_seats: int = 8
var if_load: bool = true
var is_transport_plane: bool = false

var is_waiting: bool = false
var current_target_airport = null

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		if event.pressed:
			
			for airport in get_tree().get_nodes_in_group("airports"):
				if mouse_pos.distance_to(airport.global_position) < 35.0:
					return
			if not is_transport_plane and mouse_pos.distance_to(global_position) < 40.0:
				is_transport_plane = true
				scale = Vector2(0.6, 0.6)
				z_index = 10
		elif not event.pressed and is_transport_plane:
				_drop_plane()

func _process(delta):
	if is_transport_plane or !current_route or is_waiting:
		_take_plane()
		return
	if not current_route: return
	
	var curve = current_route["curve"]
	var baked_length = curve.get_baked_length()
	
	var t_ = (current_speed * delta) / baked_length
	
	var stop_plane = 0.12
	var distance_to_target = (1.0 - t) if forward else t
	
	if distance_to_target < stop_plane:
		## снижение скорости
		var slow_factor = clamp(distance_to_target / stop_plane, 0.1, 1.0)
		var target_brake_speed = target_speed * slow_factor
		current_speed = lerp(current_speed, target_brake_speed, 0.1)
	
	
	if forward:
		t += t_
		if t >= 1.0:
			t = 1.0
			
			switch_to_next_route(true)
	else:
		t -= t_
		if t <= 0.0:
			t = 0.0
			switch_to_next_route(false)

	var dist = t * baked_length
	var new_pos = curve.sample_baked(dist)
	
	
	if current_speed > 0.1 and position.distance_to(new_pos) > 0.001:
		var target_angle = (new_pos - position).angle()
		rotation = lerp_angle(rotation, target_angle, 8.0 * delta)
	position = new_pos
	
	if (forward and t >= 1.0) or (not forward and t <= 0.0):
		var airport = current_route["end_airport"] if forward else current_route["start_airport"]
		_arrive_at_airport(airport)
		
func _arrive_at_airport(airport):
	is_waiting = true
	await handle_passengers(airport)
	is_waiting = false

func setup_with_route(route_data: Dictionary, start_t: float = 0.0):
	current_route = route_data
	t = start_t
	if route_data.has("route_color"):
		modulate = route_data["route_color"]
	
	var curve = current_route["curve"]
	var dist = t * curve.get_baked_length()
	position = curve.sample_baked(dist)
	
	play_spawn_effect()
	start_plane(3.5)

func play_spawn_effect():
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.84, 0.84), 0.6)
	
	var final_color = modulate
	modulate = Color.WHITE
	var flash = create_tween()
	flash.tween_property(self, "modulate", final_color, 0.3)


func start_plane(duration: float):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "current_speed", target_speed, duration)



func switch_to_next_route(arrived_at_end: bool):
	var arrived_airport = current_route["end_airport"] if arrived_at_end else current_route["start_airport"]
	
	_upload_passenger(arrived_airport)
	_load_passenger(arrived_airport)
	
	var next_route = null
	for route_data_item in GameData.lines_data[color + "_routes"]:
		if route_data_item != current_route:
			if route_data_item["start_airport"] == arrived_airport or route_data_item["end_airport"] == arrived_airport:
				next_route = route_data_item
				break
	
	## остановка
	set_process(false)
	current_speed = 0.0
	await get_tree().create_timer(1.6).timeout
	
	if next_route == null:
		forward = !forward
	else:
		if next_route["start_airport"] == arrived_airport:
			t = 0.0
			forward = true
		else:
			t = 1.0
			forward = false
		current_route = next_route
	
	start_plane(3.5)
	set_process(true)

	
func _upload_passenger(airport):
	var initial_cargo_size = cargo.size()
	cargo = cargo.filter(func(p_shape): return p_shape != airport.my_shape)
	
	var score = initial_cargo_size - cargo.size()
	if score > 0:
		for i in range(score):
			Events.passengers_delivery.emit()
	queue_redraw()
	
func _load_passenger(airport):
	var line_shapes = GameData.lines_data[color + "_shapes"]
	if cargo.size() >= max_seats:
		return

	var i = 0
	while (i < airport.passenger_manager.passengers.size()) and (cargo.size() < max_seats):
		var p_shape = airport.passenger_manager.passengers[i]
		
		if p_shape in line_shapes:
			cargo.append(p_shape)
			airport.passenger_manager.passengers.remove_at(i)

			await get_tree().create_timer(0.3).timeout
		else:
			i += 1
			
	if cargo.size() > 0:
		airport.queue_redraw()
		queue_redraw()


func _draw():
	var p_size = 6.1
	var spacing = 13.0
	var start_offset = Vector2(-44, 0)
	

	var p_color = Color(18.892, 18.892, 18.892, 0.475)

	for i in range(cargo.size()):
		var shape = cargo[i]
		var pos = start_offset + Vector2(i * spacing, 0)
		
		match shape:
			GameData.ShapeType.CIRCLE:
				draw_circle(pos, p_size, p_color,32.0)
			
			GameData.ShapeType.SQUARE:
				var rect = Rect2(pos - Vector2(p_size, p_size), Vector2(p_size*2, p_size*2))
				draw_rect(rect, p_color, true)
			
			GameData.ShapeType.TRIANGLE:
				var side = p_size * 2.2
				var h = side * sqrt(3) / 2
				
				var points = PackedVector2Array([
					pos + Vector2(0, -h/2),
					pos + Vector2(side/2, h/2),
					pos + Vector2(-side/2, h/2)
				])
				draw_colored_polygon(points, p_color, PackedVector2Array(), null)
				
				points.append(points[0])
				draw_polyline(points, p_color, 0.5, true)
				
				
func _take_plane():
	var canvas_transform = get_viewport().get_canvas_transform()
	var mouse_pos_world = canvas_transform.affine_inverse() * get_viewport().get_mouse_position()
	
	global_position = mouse_pos_world
	
	var found_data = _get_closest_route_data(mouse_pos_world)
	
	if found_data:
		
		modulate = modulate.lerp(found_data.color_val, 0.2)
		modulate.a = 0.7
		
		var curve = found_data.curve
		@warning_ignore("shadowed_variable_base_class")
		var offset = curve.get_closest_offset(mouse_pos_world)
		var pos1 = curve.sample_baked(offset)
		var pos2 = curve.sample_baked(offset + 2.0)
		
		var target_angle = (pos2 - pos1).angle()
		rotation = lerp_angle(rotation, target_angle, 0.15)
	else:
		modulate = modulate.lerp(Color(0.6, 0.6, 0.6, 0.5), 0.1)
		rotation = lerp_angle(rotation, 0, 0.1)

func _get_closest_route_data(global_pos):
	var min_dist = 30.0
	var closest_data = null
	
	for route in get_tree().get_nodes_in_group("routes"):
		for curve in route.my_curves:
			@warning_ignore("shadowed_variable_base_class")
			var offset = curve.get_closest_offset(global_pos)
			var point = curve.sample_baked(offset)
			var d = global_pos.distance_to(point)
			
			if d < min_dist:
				min_dist = d
				closest_data = {
					"curve": curve,
					"full_route_data": route.route_data,
					"color_val": GameData.color_values[route.route_data.color]
				}
	return closest_data

func _drop_plane():
	is_transport_plane = false
	
	scale = Vector2(0.84, 0.84) 
	z_index = 0
	
	var mouse_pos = get_global_mouse_position()
	var found_data = _get_closest_route_data(mouse_pos)
	
	if found_data:
		current_route = found_data.full_route_data.duplicate()
		current_route["curve"] = found_data.curve
		color = current_route.color

		modulate = found_data.color_val
		modulate.a = 1.0
		
		var curve = found_data.curve
		@warning_ignore("shadowed_variable_base_class")
		var offset = curve.get_closest_offset(mouse_pos)
		t = offset / curve.get_baked_length()
		position = curve.sample_baked(offset)
		
		current_speed = target_speed
		forward = true 
	else:
		GameData.start_planes += 1
		for count_label in get_tree().get_nodes_in_group("countPlane"):
			if count_label.has_method("update_counter"):
				count_label.update_counter()
		queue_free()
		self.queue_free()
		GameData.lines_data[GameData.lines_data["current color"] + "_planes"].erase(self)

func _get_lines_at_airport(airport) -> Array:
	var lines_here = []
	for c in GameData.lines_data["active colors"]:
		var routes_key = c + "_routes"
		if GameData.lines_data.has(routes_key):
			for r in GameData.lines_data[routes_key]:
				if r["start_airport"] == airport or r["end_airport"] == airport:
					if not c in lines_here: lines_here.append(c)
	return lines_here

func _can_reach_transfer_hub(target_shape) -> bool:
	var routes_key = color + "_routes"
	if not GameData.lines_data.has(routes_key): return false
	
	for r in GameData.lines_data[routes_key]:
		for a in [r["start_airport"], r["end_airport"]]:
			for l_color in _get_lines_at_airport(a):
				if l_color != color and target_shape in GameData.lines_data[l_color + "_shapes"]:
					return true
	return false

func handle_passengers(airport):
	var pm = airport.passenger_manager
	if !pm: return
	
	var remaining_cargo = []
	for p_shape in cargo:
		if p_shape == airport.my_shape:
			Events.passengers_delivery.emit()
		else:
			var on_my_line = p_shape in GameData.lines_data[color + "_shapes"]
			var can_transfer_here = false
		
			
			if not on_my_line:
				for l in _get_lines_at_airport(airport):
					if l != color and p_shape in GameData.lines_data[l + "_shapes"]:
						can_transfer_here = true
						break
			
			if can_transfer_here:
				pm.passengers.append(p_shape)
			else:
				remaining_cargo.append(p_shape)
	
	cargo = remaining_cargo
	
	var i = 0
	while i < pm.passengers.size() and cargo.size() < max_seats:
		var p_shape = pm.passengers[i]
		var can_reach_directly = p_shape in GameData.lines_data[color + "_shapes"]
		var can_help_transfer = false
		
		if not can_reach_directly:
			can_help_transfer = _can_reach_transfer_hub(p_shape)
		
		var already_on_right_line = false
		for l in _get_lines_at_airport(airport):
			if p_shape in GameData.lines_data[l + "_shapes"] and l != color:
				already_on_right_line = true
		
		if can_reach_directly or (can_help_transfer and not already_on_right_line):
			cargo.append(p_shape)
			pm.passengers.remove_at(i)
		else:
			i += 1
	
	airport.queue_redraw()
	queue_redraw()
