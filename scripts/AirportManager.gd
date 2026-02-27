extends Node
class_name AirportManager

signal airport_selected(airport: Airport)

@export var airport_scene: PackedScene
@export var spawn_points_node: Node2D
@export var initial_airport_count: int = 3
@export var mouse_hover_radius: float = 50.0

var airport_points: Array[Vector2] = []
var airports: Array[Airport] = []
var selected_airport: Airport = null

func _ready() -> void:
	_collect_spawn_points()
	_spawn_initial_airports()

func _collect_spawn_points() -> void:
	if not spawn_points_node:
		return
		
	for child in spawn_points_node.get_children():
		if child is Marker2D:
			airport_points.append(child.global_position)
	airport_points.shuffle()

func _spawn_initial_airports() -> void:
	for i in range(initial_airport_count):
		spawn_airport()

func spawn_airport() -> void:
	if airport_points.is_empty() or not airport_scene:
		return
		
	var airport = airport_scene.instantiate()
	airport.position = airport_points.pop_back()
	airport.radius = mouse_hover_radius
	airport.selected.connect(_on_airport_selected)
	
	add_child(airport)
	airports.append(airport)

func get_airport_at_position(position: Vector2) -> Airport:
	for airport in airports:
		if airport.is_mouse_nearby(position):
			return airport
	return null

func _on_airport_selected(airport: Airport) -> void:
	selected_airport = airport
	airport_selected.emit(airport)

func clear_selection() -> void:
	selected_airport = null
