extends Node2D

var plane_scene = load("res://scene/Plane.tscn")
var my_curves: Array[Curve2D] = []
var lines_data = GameData.lines_data
var route_data

func _ready():
	add_to_group("routes")
	
func create_line(airport_a, airport_b):
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
	var offset
	
		
	var mid = (p0 + p2) / 2
	if p2.x < p0.x:
		offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	else: 
		offset = (p0 - p2).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
		
	var control_relative = (mid + offset) - p0
 
	curve.add_point(p0, Vector2.ZERO, control_relative)
	curve.add_point(p2)
 
	line.points = curve.get_baked_points()
	
	my_curves.append(curve)
	
	var color_name = lines_data["current color"]
	
	var shapes_list = GameData.lines_data[color_name + "_shapes"]
	
	if not airport_a.my_shape in shapes_list:
		shapes_list.append(airport_a.my_shape)
		
	if not airport_b.my_shape in shapes_list:
		shapes_list.append(airport_b.my_shape) 
	
	route_data = {
		"curve" = curve,
		"start_airport" = airport_a,
		"end_airport" = airport_b,
		"color" = color_name,
		"route_color" = GameData.color_values[color_name]
	}
	
	lines_data[color_name + "_routes"].append(route_data)
	
	if not lines_data["in_" + color_name]:
		if GameData.start_planes > 0:
			spawn_plane(route_data, 0.0)
			lines_data["in_" + color_name] = true

@warning_ignore("shadowed_variable")
func spawn_plane(route_data: Dictionary, start_t: float):
	GameData.start_planes -= 1
	var plane = plane_scene.instantiate()
	add_child(plane)
	
	plane.current_route = route_data
	plane.color = route_data["color"]
	plane.t = start_t
	
	lines_data[route_data["color"] + "_planes"].append(plane)
	plane.setup_with_route(route_data, start_t)
	
	var CountPlane = get_tree().get_first_node_in_group("countPlane")
	if CountPlane:
		CountPlane.on_plane_spawned()
