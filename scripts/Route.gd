extends Node2D

var plane_scene = load("res://scene/Plane.tscn")


func create_line(airport_a, airport_b, lines_data):
	
	var line = Line2D.new()
	add_child(line)
	line.width = 4.0
	line.default_color = lines_data["current hex color"]
	line.z_index = -1
 
	var curve = Curve2D.new()
	var p0 = airport_a.position
	var p2 = airport_b.position
 
	var mid = (p0 + p2) / 2
	var offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	var p1_a = mid + offset
 
	var control_relative = p1_a - p0
 
	curve.add_point(p0, Vector2.ZERO, control_relative)
	curve.add_point(p2)
 
	line.points = curve.get_baked_points()
	
	lines_data[lines_data["current color"] + " curves"].append(curve)
	if not(lines_data["is " + lines_data["current color"]]):
		if plane_scene:
			var plane = plane_scene.instantiate()
			add_child(plane)
			plane.setup_with_curve(curve)
			
			lines_data["is " + lines_data["current color"]] = true
			lines_data[lines_data["current color"] + " planes count"] += 1
			
