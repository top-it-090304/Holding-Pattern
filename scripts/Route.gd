extends Node2D

var plane_scene = load("res://scene/Plane.tscn")
var my_curves: Array[Curve2D] = []

func _ready():
	add_to_group("routes")

func create_line(airport_a, airport_b, lines_data):
	var line = Line2D.new()
	add_child(line)
	line.width = 6.0
	line.default_color = lines_data["current hex color"]
	line.z_index = -1
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
 
	var curve = Curve2D.new()
	var p0 = airport_a.position
	var p2 = airport_b.position
 
	var mid = (p0 + p2) / 2
	var offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	var control_relative = (mid + offset) - p0
 
	curve.add_point(p0, Vector2.ZERO, control_relative)
	curve.add_point(p2)
 
	line.points = curve.get_baked_points()
	
	my_curves.append(curve)
	
	var color_name = lines_data["current color"]
	if lines_data["in " + color_name] == false:
		if not lines_data["in " + color_name]:
			spawn_plane(curve, 0.0)
			lines_data["in " + color_name] = true

func spawn_plane(curve: Curve2D, start_t: float):
	GameData.start_planes -= 1
	var plane = plane_scene.instantiate()
	add_child(plane)
	plane.setup_with_curve(curve, start_t)
