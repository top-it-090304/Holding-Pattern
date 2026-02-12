extends Node2D

@export var airport_scene: PackedScene = preload("res://scene/Airport.tscn")
@export var route_scene: PackedScene = preload("res://scene/Route.tscn")

@onready var spawn_points_node := $AirportSpawn
var airport_points: Array[Vector2] = []

var selected_airport = null
var pred_line: Line2D


func _ready():
 ## мнимая линия
	pred_line = Line2D.new()
	pred_line.width = 2.0
	pred_line.default_color = Color.WHITE
	add_child(pred_line)
	if selected_airport == null:
		pred_line.clear_points()
		

 ## точки спавна аэропортов
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
		push_error("Нет точек")
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
			route.create_line(selected_airport, airport)
  
		selected_airport = null

## вызов новой точки после таймера
func _on_spawn_timer_timeout():
	spawn_airport()
	
	
