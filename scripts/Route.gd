extends Node2D

var plane_scene = load("res://scene/Plane.tscn")
var my_curves: Array[Curve2D] = []

func _ready():
	add_to_group("routes")

func create_line(airport_a, airport_b, lines_data):
	var line = Line2D.new()
	add_child(line)
	line.width = 15
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
	lines_data[color_name + " curves"].append(curve)
 
 ## проверка чтобы эта была новая линия другого цвета
	var active_key = "in " + color_name
	if (lines_data[active_key] == false):
		spawn_plane(curve)
		lines_data[active_key] = true
  

func spawn_plane(curve: Curve2D):
	if plane_scene and GameData.start_planes > 0:
		var plane = plane_scene.instantiate()
		add_child(plane)
		plane.setup_with_curve(curve)
		GameData.start_planes -= 1


func add_plane_button() -> bool:
	if my_curves.is_empty(): return false
	spawn_plane(my_curves.pick_random())
	return true
