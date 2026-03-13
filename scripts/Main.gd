extends Node2D

var airport_scene = load("res://scene/Airport.tscn")
var route_scene = load("res://scene/Route.tscn")

@onready var spawn_points := $AirportSpawn
@onready var camera := $Camera2D
@onready var score_pack = $UI/ScorePack
@onready var score_label = $UI/ScorePack/Score

var passengers_delivery: int = 0

var start_shapes = [
	GameData.ShapeType.CIRCLE,
	GameData.ShapeType.SQUARE,
	GameData.ShapeType.TRIANGLE
]

var all_zones: Array = []
var active_airport: Array[Vector2] = []
var airport_points: Array[Vector2] = []

var current_phase: int = 0
var max_phases: int = 0

var target_zoom := Vector2(1.9, 1.9)

var selected_airport = null
var is_drawing: bool = false
var pred_line: Line2D

var lines_data = GameData.lines_data

func _ready():
	score_pack.modulate.a = 0
	score_pack.scale = Vector2(0.5, 0.5)
	pred_line = Line2D.new()
	pred_line.width = 6.0
	pred_line.z_index = -1
	add_child(pred_line)
 
	for zone_node in spawn_points.get_children():
		var zone_points: Array[Vector2] = []
		for marker in zone_node.get_children():
			if marker is Marker2D:
				zone_points.append(marker.global_position)
		zone_points.shuffle()
		all_zones.append(zone_points)
		
	max_phases = all_zones.size()
	unlock_next_phase()
	
	Events.passengers_delivery.connect(_on_passengers_delivery)
	animate_score()
		
	var passenger_timer = Timer.new()
	passenger_timer.wait_time = 3.0
	passenger_timer.autostart = true
	passenger_timer.timeout.connect(_on_passenger_timer_timeout)
	add_child(passenger_timer)
	
	var phase_timer = Timer.new()
	phase_timer.wait_time = 150.0 ## таймер на новую зону
	phase_timer.autostart = true
	phase_timer.timeout.connect(_on_phase_timer_timeout)
	add_child(phase_timer)
	
	for i in range(3):
		spawn_airport()
		
	score_pack.scale = Vector2.ZERO
	score_pack.modulate.a = 0
	get_tree().create_timer(1.0).timeout.connect(animate_score)
	
func _process(delta):
	if is_drawing and selected_airport:
		var current_color = GameData.lines_data["current hex color"]
		pred_line.default_color = Color(current_color.r, current_color.g, current_color.b)
		
		selected_airport.draw_stroke(true)
		
		line_draw(selected_airport.global_position, get_global_mouse_position())
		check_airport()
	if camera:
		var zoom_speed = 0.03 ## скорость камеры
		camera.zoom = camera.zoom.lerp(target_zoom, zoom_speed * delta)
	
func animate_score():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(score_pack, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(score_pack, "modulate:a", 1.0, 0.4)

func _on_passengers_delivery():
	passengers_delivery += 1
	score_label.text = str(passengers_delivery)
	
func _on_phase_timer_timeout():
	unlock_next_phase()
	

func unlock_next_phase():
	if current_phase < max_phases:
		active_airport.append_array(all_zones[current_phase])
		active_airport.shuffle()
		
		var zoom_value = 1.9 - (current_phase * 0.15)
		
		target_zoom = Vector2(zoom_value, zoom_value)
		
		current_phase += 1


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			stop_draw()




func line_draw(pos1: Vector2, pos2: Vector2):
	var curve = Curve2D.new()
	var p0 = pos1
	var p2 = pos2
	
	if p2.x > p0.x:
		var C = p0
		p0 = p2
		p2 = C
		
	var mid = (p0 + p2) / 2
	var offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	var control_point = (mid + offset) - p0
 
	curve.add_point(p0, Vector2.ZERO, control_point)
	curve.add_point(p2)
	pred_line.points = curve.get_baked_points()

func check_airport():
	var mouse_pos = get_global_mouse_position()
	
	for airport in get_tree().get_nodes_in_group("airports"):
		

		if airport != selected_airport and airport.global_position.distance_to(mouse_pos) < 50 and ((len(lines_data[lines_data["current color"] + "_airports"]) >= 3 and airport == lines_data[lines_data["current color"] + "_airports"][0]) or (airport not in lines_data[lines_data["current color"] + "_airports"])):
			airport.activate_pulse() 
			
			if not lines_data["in_" + lines_data["current color"]]:
				lines_data[lines_data["current color"] + "_airports"].append(selected_airport)
			lines_data[lines_data["current color"] + "_airports"].append(airport)
			
			create_route(selected_airport, airport)
			
			selected_airport = airport
			selected_airport.draw_stroke(true)

func create_route(a, b):
	var route = route_scene.instantiate()
	add_child(route)
	route.create_line(a, b)

func stop_draw():
	for airport in get_tree().get_nodes_in_group("airports"):
		airport.draw_stroke(false)
	selected_airport = null
	is_drawing = false
	pred_line.clear_points()

func spawn_airport():
	if active_airport.is_empty(): return
	var inst = airport_scene.instantiate()
	inst.position = active_airport.pop_back()
	
	if not start_shapes.is_empty():
		inst.forced_shape = start_shapes.pop_front()
		
	inst.add_to_group("airports")
	inst.airport_selected.connect(_on_airport_selected)
	inst.end_game.connect(game_over)
	add_child(inst)



func _on_airport_selected(airport):
	if lines_data["in_" + lines_data["current color"]] and airport == lines_data[lines_data["current color"] + "_airports"][0]:
		var a = lines_data[lines_data["current color"] + "_airports"][0]
		lines_data[lines_data["current color"] + "_airports"][0] = lines_data[lines_data["current color"] + "_airports"][-1]
		lines_data[lines_data["current color"] + "_airports"][-1] = a
	
	selected_airport = airport
	
	is_drawing = true
	
func _on_passenger_timer_timeout():
	var airports = get_tree().get_nodes_in_group("airports")
	airports.shuffle()
	for airport in airports:
		if airport.passengers.size() < 9:
			airport.spawn_passenger()
			return
			
	if airports.is_empty(): return
	var random_airport = airports.pick_random()
	if random_airport.passengers.size() >= 9:
		return
	random_airport.spawn_passenger()
	
func game_over(_failed_airport):
	print("stop")
	get_tree().paused = true
	$UI.visible = false
	
	camera.process_mode = Node.PROCESS_MODE_ALWAYS
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(camera, "global_position", _failed_airport.global_position, 2.5)
	
	var crash_zoom = Vector2(3.5, 3.5)
	tween.tween_property(camera, "zoom", crash_zoom, 2.5)
	tween.tween_property(camera, "rotation", 0.45, 2.5)

## кнопки
func _on_yb_toggled(_t):
	lines_data["current color"] = "yellow"
	lines_data["current hex color"] = Color(1.0, 0.812, 0.039, 1.0)

func _on_bb_toggled(_t):
	lines_data["current color"] = "blue"
	lines_data["current hex color"] = Color(0.0, 0.323, 0.983, 1.0)

func _on_rb_toggled(_t):
	lines_data["current color"] = "red"
	lines_data["current hex color"] = Color(1.0, 0.0, 0.0, 1.0)

func _on_spawn_timer_timeout():
	spawn_airport()
