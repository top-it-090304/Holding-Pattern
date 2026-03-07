extends Sprite2D

var current_route: Dictionary
var t: float = 0.0         
var speed: float = 180.0
var current_speed: float = 0.0
var forward: bool = true
var color: String

func setup_with_route(route_data: Dictionary, start_t: float = 0.0):
	current_route = route_data
	t = start_t
	if route_data.has("route_color"):
		modulate = route_data["route_color"]
	
	var curve = current_route["curve"]
	var dist = t * curve.get_baked_length()
	position = curve.sample_baked(dist)
	
	play_spawn_effect()
	razgon_plane(3.5)

func play_spawn_effect():
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.46, 0.46), 0.6)
	
	var final_color = modulate
	modulate = Color.WHITE
	var flash = create_tween()
	flash.tween_property(self, "modulate", final_color, 0.3)

func razgon_plane(duration: float):
	current_speed = 20.0
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "current_speed_px", speed, duration)

func _process(delta):
	if not current_route: return
	
	var curve = current_route["curve"]
	var baked_length = curve.get_baked_length()
	
	var t_ = (current_speed * delta) / baked_length

	var stop_plane = 0.15
	var distance_to_target = (1.0 - t) if forward else t
	
	if distance_to_target < stop_plane:
		## снижение скорости
		var slow_ = clamp(distance_to_target / stop_plane, 0.2, 1.0)
		current_speed = lerp(current_speed, speed * slow_, 0.1)
	else:
		current_speed = lerp(current_speed, speed, 0.05)
	
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
	
	look_at(new_pos)
	
	position = new_pos

func switch_to_next_route(arrived_at_end: bool):
	var arrived_airport = current_route["end_airport"] if arrived_at_end else current_route["start_airport"]
	
	var next_route = null
	for route_data_item in GameData.lines_data[color + "_routes"]:
		if route_data_item != current_route:
			if route_data_item["start_airport"] == arrived_airport or route_data_item["end_airport"] == arrived_airport:
				next_route = route_data_item
				break
	

	set_process(false)
	current_speed = 0.0
	await get_tree().create_timer(0.8).timeout
	
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
	
	razgon_plane(1.0) 
	set_process(true)
