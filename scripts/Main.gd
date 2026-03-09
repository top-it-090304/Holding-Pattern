extends Node2D

var airport_scene = load("res://scene/Airport.tscn")
var route_scene = load("res://scene/Route.tscn")

@onready var spawn_points_node := $AirportSpawn
var airport_points: Array[Vector2] = []

var selected_airport = null
var is_drawing: bool = false
var pred_line: Line2D

var lines_data = GameData.lines_data

func _ready():
	pred_line = Line2D.new()
	pred_line.width = 6.0
	pred_line.z_index = -1
	add_child(pred_line)
 
	for child in spawn_points_node.get_children():
		if child is Marker2D:
			airport_points.append(child.global_position)
	airport_points.shuffle()
 
	for i in range(3):
		spawn_airport()
		
	var passenger_timer = Timer.new()
	passenger_timer.wait_time = 1.0 # Каждые 3 секунды появляется пассажир
	passenger_timer.autostart = true
	passenger_timer.timeout.connect(_on_passenger_timer_timeout)
	add_child(passenger_timer)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			stop_draw()

func _process(_delta):
	if is_drawing and selected_airport:
		var current_color = GameData.lines_data["current hex color"]
		pred_line.default_color = Color(current_color.r, current_color.g, current_color.b)
		
		selected_airport.draw_stroke(true)
		
		line_draw(selected_airport.global_position, get_global_mouse_position())
		check_airopotr()

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

func check_airopotr():
	var mouse_pos = get_global_mouse_position()
	
	
	for airport in get_tree().get_nodes_in_group("airports"):
		if airport != selected_airport and airport.global_position.distance_to(mouse_pos) < 50:
			airport.activate_pulse() 
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
	if airport_points.is_empty(): return
	var inst = airport_scene.instantiate()
	inst.position = airport_points.pop_back()
	inst.add_to_group("airports")
	inst.airport_selected.connect(_on_airport_selected)
	add_child(inst)

func _on_airport_selected(airport):
	selected_airport = airport
	is_drawing = true
	
func _on_passenger_timer_timeout():
	var airports = get_tree().get_nodes_in_group("airports")
	if airports.is_empty(): return
	
	# Выбираем случайную станцию
	var random_airport = airports.pick_random()
	
	# Спавним на ней пассажира
	random_airport.spawn_passenger()

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
