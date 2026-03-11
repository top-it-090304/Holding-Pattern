extends Sprite2D

var current_route: Dictionary
var t: float = 0.0         
var target_speed: float = 90.0
var current_speed: float = 0.0  
var forward: bool = true
var color: String

var cargo: Array = []
var max_seats: int = 6

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
	tween.tween_property(self, "scale", Vector2(0.46, 0.46), 0.6)
	
	var final_color = modulate
	modulate = Color.WHITE
	var flash = create_tween()
	flash.tween_property(self, "modulate", final_color, 0.3)


func start_plane(duration: float):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "current_speed", target_speed, duration)

func _process(delta):
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
	
	if current_speed > 0.1:
		look_at(new_pos)
	position = new_pos

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
	
	if cargo.size() < initial_cargo_size:
		print("пассажиры перевезены")
		queue_redraw()
	
func _load_passenger(airport):
	var line_shapes = GameData.lines_data[color + "_shapes"]
	
	if cargo.size() >= max_seats:
		return

	var i = 0
	while (i < airport.passengers.size()) and (cargo.size() < max_seats):
		var p_shape = airport.passengers[i]
		
		if p_shape in line_shapes:
			cargo.append(p_shape)
			airport.passengers.remove_at(i)
			print("пассажир взят")
			
			await get_tree().create_timer(0.3).timeout
			print(cargo.size())
		else:
			i += 1
			
	if cargo.size() > 0:
		airport.queue_redraw()
		queue_redraw()


func _draw():
	var p_size = 12.0
	var spacing = 13.0
	var start_offset = Vector2(-44, 0)
	

	var p_color = Color(18.892, 18.892, 18.892, 0.475)

	for i in range(cargo.size()):
		var shape = cargo[i]
		var pos = start_offset + Vector2(i * spacing, 0)
		
		match shape:
			GameData.ShapeType.CIRCLE:
				draw_circle(pos, p_size / 2, p_color)
			GameData.ShapeType.SQUARE:
				draw_rect(Rect2(pos - Vector2(p_size/2, p_size/2), Vector2(p_size, p_size)), p_color)
			GameData.ShapeType.TRIANGLE:
				var points = PackedVector2Array([
					pos + Vector2(0, -p_size/2),
					pos + Vector2(p_size/2, p_size/2),
					pos + Vector2(-p_size/2, p_size/2)
				])
				draw_colored_polygon(points, p_color)
		
