extends Node2D

var airport_scene = load("res://scene/Airport.tscn")
var route_scene = load("res://scene/Route.tscn")

@onready var spawn_points_node := $AirportSpawn
var airport_points: Array[Vector2] = []
var points = []

var selected_airport = null
var pred_line: Line2D


func _ready():
	pred_line = Line2D.new()
	pred_line.width = 2.0
	pred_line.default_color = Color.WHITE
	add_child(pred_line)
	
	for child in spawn_points_node.get_children():
		if child is Marker2D:
			airport_points.append(child.global_position)

	airport_points.shuffle()

func _process(_delta):
	if selected_airport:
		pred_line.clear_points()
		pred_line.add_point(selected_airport.position)
		pred_line.add_point(get_global_mouse_position())
	else:
		pred_line.clear_points()

func spawn_airport():
	if airport_points.is_empty():
		return

	var inst = airport_scene.instantiate()
	inst.position = airport_points.pop_back()
	inst.airport_selected.connect(_on_airport_selected)
	add_child(inst)

func _on_airport_selected(airport):
	if selected_airport == null:
		selected_airport = airport
	else:
		if selected_airport != airport:
			var route = route_scene.instantiate()
			add_child(route)
			route.create_line(selected_airport, airport, line_color)
  
		selected_airport = null


func _on_spawn_timer_timeout():
	spawn_airport()

signal color_changed(new_color)

var line_color = Color(1, 1, 0, 0.7)

func _on_yb_toggled(on_toggled: bool):
	line_color = Color(1, 1, 0, 0.7)
	color_changed.emit(line_color)
	print("yb toggled")

func _on_bb_toggled(on_toggled: bool):
	line_color = Color(0, 0, 1, 0.7)
	color_changed.emit(line_color)
	print("bb toggled")

func _on_rb_toggled(on_toggled: bool):
	line_color = Color(1, 0, 0, 0.7)
	color_changed.emit(line_color)
	print("rb toggled")
