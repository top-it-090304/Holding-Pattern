extends Sprite2D

var current_route: Dictionary
var t: float = 0.0         
var speed: float = 0.4     
var forward: bool = true
var color: String

func setup_with_route(route_data: Dictionary, start_t: float = 0.0):
	current_route = route_data
	t = start_t
	if route_data.has("route_color"):
		modulate = route_data["route_color"]
	
	var dist = t * current_route["curve"].get_baked_length()
	position = current_route["curve"].sample_baked(dist)
	
	play_spawn_effect()
	
func play_spawn_effect():
	## анимация масштаба
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.46, 0.46), 0.6)
	
	## вспышка
	var final_color = modulate
	modulate = Color.WHITE
	var flash = create_tween()
	flash.tween_property(self, "modulate", final_color, 0.3)

func _process(delta):
	if not current_route: return
	
	var curve = current_route["curve"]
	var baked_length = curve.get_baked_length()
	
	if forward:
		t += speed * delta
		if t >= 1.0:
			t = 1.0
			switch_to_next_route(true)
	else:
		t -= speed * delta
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
	for route_data in GameData.lines_data[color + "_routes"]:
		if route_data != current_route:
			if route_data["start_airport"] == arrived_airport or route_data["end_airport"] == arrived_airport:
				next_route = route_data
				break
	
	if next_route == null:
		forward = !forward
		set_process(false)
		await get_tree().create_timer(0.8).timeout
		set_process(true)
		return
	
	var start_t: float
	if next_route["start_airport"] == arrived_airport:
		start_t = 0.0
		forward = true
	else:
		start_t = 1.0
		forward = false
	
	set_process(false)
	await get_tree().create_timer(0.8).timeout
	current_route = next_route
	t = start_t
	set_process(true)
