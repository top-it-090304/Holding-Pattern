extends Node
class_name RouteManager

@export var route_scene: PackedScene
@export var preview_line_color: Color = Color(1, 1, 1, 0.5)
@export var preview_line_width: float = 3.0
@export var preview_z_index: int = 10

var preview_line: Line2D
var is_drawing: bool = false
var current_color: Color = Color(1, 1, 0, 0.7)
var routes: Array[Route] = []

func _ready() -> void:
	_create_preview_line()

func _create_preview_line() -> void:
	preview_line = Line2D.new()
	preview_line.width = preview_line_width
	preview_line.default_color = preview_line_color
	preview_line.z_index = preview_z_index
	add_child(preview_line)

func start_drawing() -> void:
	is_drawing = true

func stop_drawing() -> void:
	is_drawing = false
	preview_line.clear_points()

func update_preview_line(start_position: Vector2, end_position: Vector2) -> void:
	var points = _calculate_bezier_points(start_position, end_position)
	preview_line.points = points

func _calculate_bezier_points(p0: Vector2, p2: Vector2) -> PackedVector2Array:
	var curve = Curve2D.new()
	var mid = (p0 + p2) / 2
	var offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	var control_point = (mid + offset) - p0
	
	curve.add_point(p0, Vector2.ZERO, control_point)
	curve.add_point(p2)
	
	return curve.get_baked_points()

func create_route(airport_a: Airport, airport_b: Airport) -> void:
	if not route_scene:
		return
		
	var route = route_scene.instantiate()
	add_child(route)
	route.initialize(airport_a, airport_b, current_color)
	routes.append(route)

func set_color(new_color: Color) -> void:
	current_color = new_color
