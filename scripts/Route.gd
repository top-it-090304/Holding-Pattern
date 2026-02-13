extends Node2D

var plane_scene = preload("res://scene/Plane.tscn")

func create_line(airport_a, airport_b):
	var line = Line2D.new()
	add_child(line)
	line.width = 3.0
	line.default_color = Color(0.3, 0.7, 1.0, 0.5)
	line.z_index = -1
 
	var curve = Curve2D.new()
	var p0 = airport_a.position
	var p2 = airport_b.position
 
	var mid = (p0 + p2) / 2
	var offset = (p2 - p0).rotated(90).normalized() * (p0.distance_to(p2) * 0.2)
	var p1_a = mid + offset
 
	var control_relative = p1_a - p0
 
	curve.add_point(p0, Vector2.ZERO, control_relative)
	curve.add_point(p2)
 
	line.points = curve.get_baked_points()
 
	var plane = plane_scene.instantiate()
	plane.z_index = -1
	add_child(plane)
	plane.setup_with_curve(curve)
