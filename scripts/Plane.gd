extends Sprite2D

var current_route: Dictionary
var t: float = 0.0         
var target_speed: float = 90.0
var current_speed: float = 0.0  
var forward: bool = true
var color: String
var is_big: bool = false

var cargo: Array = []
var max_seats: int = 6
var is_transport_plane: bool = false
var is_loading = false

var is_waiting: bool = false
var current_target_airport = null

var is_fading: bool = false
var pending_delete: bool = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if pending_delete:
			return
			
		var mouse_pos = get_global_mouse_position()
		
		if event.pressed:
			if GameData.is_take_plane: 
				return
				
			var grabbed_handle = _is_mouse_over_any_handle(mouse_pos)
			if grabbed_handle:
				return
				
			for airport in get_tree().get_nodes_in_group("airports"):
				if mouse_pos.distance_to(airport.global_position) < 35.0:
					return
		

			if not is_transport_plane and mouse_pos.distance_to(global_position) < 40.0:
				is_transport_plane = true
				GameData.is_take_plane = true
				scale = Vector2(0.8, 0.8)
				z_index = 10
				
		elif not event.pressed and is_transport_plane:
			is_transport_plane = false
			GameData.is_take_plane = false
			_drop_plane()

func _is_mouse_over_any_handle(mouse_pos: Vector2) -> bool:
	for route in get_tree().get_nodes_in_group("routes"):
		if is_instance_valid(route):
			if is_instance_valid(route.handle_start) and route.handle_start.visible:
				if mouse_pos.distance_to(route.handle_start.global_position) < 35.0:
					return true
			if is_instance_valid(route.handle_end) and route.handle_end.visible:
				if mouse_pos.distance_to(route.handle_end.global_position) < 35.0:
					return true
	return false

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
	tween.tween_property(self, "scale", Vector2(0.66, 0.66), 0.6)
	
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
	
	if pending_delete:
		_finish_delete(arrived_airport)
		return
	
	var next_route = null
	for route_data_item in GameData.lines_data[color + "_routes"]:
		if route_data_item != current_route:
			if route_data_item["start_airport"] == arrived_airport or route_data_item["end_airport"] == arrived_airport:
				next_route = route_data_item
				break
	
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
			
		var old_route = current_route["route"]
		if is_instance_valid(old_route):
			old_route.unregister_plane(self)
			
		current_route = next_route
		
		var new_route = current_route["route"]
		if is_instance_valid(new_route):
			new_route.register_plane(self)
	
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
	var pm = airport.passenger_manager
	if !pm or is_loading or cargo.size() >= max_seats:
		return

	is_loading = true
	var potential_passengers = pm.passengers.duplicate()
	
	for p_shape in potential_passengers:
		if cargo.size() >= max_seats:
			break
			
		var can_take = p_shape in GameData.lines_data[color + "_shapes"]
			
		if can_take:
			var idx = pm.passengers.find(p_shape)
			if idx != -1:
				pm.passengers.remove_at(idx)
				airport.queue_redraw()
				await get_tree().create_timer(0.15).timeout
				
				cargo.append(p_shape)
				queue_redraw()
				await get_tree().create_timer(0.15).timeout

	is_loading = false

func _draw():
	var p_size = 6.0
	var spacing = 13.0
	var start_offset = Vector2(-44, 0)
	var p_color = Color(18.892, 18.892, 18.892, 0.475)

	for i in range(cargo.size()):
		var shape = cargo[i]
		var pos = start_offset + Vector2(i * spacing, 0)
			
		match shape:
			GameData.ShapeType.CIRCLE:
				draw_circle(pos, p_size, p_color, 32.0)
			GameData.ShapeType.SQUARE:
				var s = p_size
				var rect = Rect2(pos - Vector2(s, s), Vector2(s * 2, s * 2))
				draw_rect(rect, p_color, true)
			GameData.ShapeType.TRIANGLE:
				var size = p_size * 2.2
				var h = size * sqrt(3) / 2
				var points = PackedVector2Array([
					pos + Vector2(0, -h/2),
					pos + Vector2(size/2, h/2),
					pos + Vector2(-size/2, h/2)
				])
				draw_colored_polygon(points, p_color)
			GameData.ShapeType.PENTAGON:
				var size = p_size * 1.2
				var points = PackedVector2Array()
				for c in range(5):
					var angle = deg_to_rad(c * 72 - 90)
					points.append(pos + Vector2(cos(angle), sin(angle)) * size)
				draw_colored_polygon(points, p_color)
			GameData.ShapeType.GEM:
				var sw = p_size * 1.0
				var sh = p_size * 1.5
				var points = PackedVector2Array([
					pos + Vector2(0, -sh),
					pos + Vector2(sw, 0),
					pos + Vector2(0, sh),
					pos + Vector2(-sw, 0)
				])
				draw_colored_polygon(points, p_color)
			GameData.ShapeType.PLUS:
				var s = p_size * 0.8
				var t = s * 0.3
				var points = PackedVector2Array([
					pos + Vector2(-t, -s), pos + Vector2(t, -s), pos + Vector2(t, -t),
					pos + Vector2(s, -t),  pos + Vector2(s, t),  pos + Vector2(t, t),
					pos + Vector2(t, s),   pos + Vector2(-t, s), pos + Vector2(-t, t),
					pos + Vector2(-s, t),  pos + Vector2(-s, -t), pos + Vector2(-t, -t)
				])
				draw_colored_polygon(points, p_color)

func _take_plane():
	if pending_delete:
		return
		
	GameData.lines_data[color + "_planes"].erase(self)
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
		if route.pending_delete:
			continue
			
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
	scale = Vector2(0.66, 0.66) 
	z_index = 0
	
	var mouse_pos = get_global_mouse_position()
	var found_data = _get_closest_route_data(mouse_pos)
	
	if found_data:
		current_route["route"].remove_child(self)
		
		var old_route = current_route["route"]
		if is_instance_valid(old_route):
			old_route.unregister_plane(self)
			
		current_route = found_data.full_route_data.duplicate()
		
		var new_route = current_route["route"]
		if is_instance_valid(new_route):
			new_route.unregister_plane(self)
		current_route["route"].add_child(self)
		current_route["curve"] = found_data.curve
		color = current_route.color
		GameData.lines_data[color + "_planes"].append(self)
		modulate = found_data.color_val
		modulate.a = 1.0
		
		var curve = found_data.curve
		@warning_ignore("shadowed_variable_base_class")
		var offset = curve.get_closest_offset(mouse_pos)
		t = offset / curve.get_baked_length()
		position = curve.sample_baked(offset)
		forward = true 
	else:
		GameData.start_planes += 1
		for count_label in get_tree().get_nodes_in_group("countPlane"):
			if count_label.has_method("update_counter"):
				count_label.update_counter()
		queue_free()
		GameData.lines_data[color + "_planes"].erase(self)

func _get_lines_at_airport(airport) -> Array:
	var lines_here = []
	for c in GameData.lines_data["active colors"]:
		var routes_key = c + "_routes"
		if GameData.lines_data.has(routes_key):
			for r in GameData.lines_data[routes_key]:
				if r["start_airport"] == airport or r["end_airport"] == airport:
					if not c in lines_here: lines_here.append(c)
	return lines_here

func can_reach_destination(start_airport, target_shape, max_transfers = 3) -> bool:
	var queue = []
	var visited_lines = []
	
	for line in _get_lines_at_airport(start_airport):
		queue.append({"line": line, "transfers": 0})
		visited_lines.append(line)
	
	var head = 0
	while head < queue.size():
		var current = queue[head]
		head += 1
		
		var l_color = current["line"]
		var depth = current["transfers"]
		
		if target_shape in GameData.lines_data[l_color + "_shapes"]:
			return true
			
		if depth < max_transfers:
			for airport in _get_airports_on_line(l_color):
				for next_line in _get_lines_at_airport(airport):
					if not next_line in visited_lines:
						visited_lines.append(next_line)
						queue.append({"line": next_line, "transfers": depth + 1})
						
	return false
	
func _can_reach_transfer_hub(target_shape) -> bool:
	var routes_key = color + "_routes"
	if not GameData.lines_data.has(routes_key): return false
	
	for r in GameData.lines_data[routes_key]:
		for a in [r["start_airport"], r["end_airport"]]:
			if can_reach_destination(a, target_shape, 2):
				return true
	return false

func _get_airports_on_line(line_color) -> Array:
	var airports = []
	var routes_key = line_color + "_routes"
	if GameData.lines_data.has(routes_key):
		for r in GameData.lines_data[routes_key]:
			if not r["start_airport"] in airports: airports.append(r["start_airport"])
			if not r["end_airport"] in airports: airports.append(r["end_airport"])
	return airports
	
func get_route_path(start_airport, target_shape, max_transfers = 5):
	var queue = []
	
	for line in _get_lines_at_airport(start_airport):
		queue.append([start_airport, [line], [line]])

	var head = 0
	while head < queue.size():
		var current_data = queue[head]
		head += 1
		
		var current_airport = current_data[0]
		var current_path = current_data[1]
		var visited_lines = current_data[2]
		
		var current_line = current_path.back()
		
		if target_shape in GameData.lines_data[current_line + "_shapes"]:
			return current_path

		if current_path.size() < max_transfers:
			for airport in _get_airports_on_line(current_line):
				for next_line in _get_lines_at_airport(airport):
					if not next_line in visited_lines:
						var new_path = current_path.duplicate()
						new_path.append(next_line)
						
						var new_visited = visited_lines.duplicate()
						new_visited.append(next_line)
						
						queue.append([airport, new_path, new_visited])
	
	return []

func handle_passengers(airport):
	var pm = airport.passenger_manager
	if !pm or is_loading: return
	is_loading = true
	
	var remaining_cargo = []
	for p_shape in cargo:
		if p_shape == airport.my_shape:
			Events.passengers_delivery.emit()
		else:
			var path = get_route_path(airport, p_shape)
			if path.size() > 0 and path[0] != color:
				pm.passengers.append(p_shape)
			elif path.size() == 0:
				pm.passengers.append(p_shape)
			else:
				remaining_cargo.append(p_shape)
	
	cargo = remaining_cargo
	var i = 0
	while i < pm.passengers.size() and cargo.size() < max_seats:
		var p_shape = pm.passengers[i]
		var path = get_route_path(airport, p_shape)
		
		if path.size() > 0 and path[0] == color:
			pm.passengers.remove_at(i)
			airport.queue_redraw()
			await get_tree().create_timer(0.15).timeout
			if not is_instance_valid(airport) or not is_instance_valid(self): return
			cargo.append(p_shape)
			queue_redraw()
			await get_tree().create_timer(0.15).timeout
		else:
			i += 1
	
	airport.queue_redraw()
	queue_redraw()
	is_loading = false


func begin_delete():
	if pending_delete:
		return
		
	pending_delete = true
	is_fading = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.4, 0.25)
	
func _finish_delete(arrived_airport):
	set_process(false)
	is_waiting = false

	cargo.clear()

	if current_route:
		var route = current_route["route"]

		if is_instance_valid(route):
			route.unregister_plane(self)

	var tween = create_tween().set_parallel(true)

	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)

	if is_big:
		GameData.big_planes += 1
	else:
		GameData.start_planes += 1

	var group = "countBigPlane" if is_big else "countPlane"
	var label = get_tree().get_first_node_in_group(group)

	if label and label.has_method("update_counter"):
		label.update_counter()

	tween.chain().tween_callback(queue_free)
