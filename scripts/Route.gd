extends Node2D

var handle_scene = preload("res://scene/RouteHand.tscn")
var handle_start: Area2D
var handle_end: Area2D

var plane_scene = load("res://scene/Plane.tscn")
var big_plane_scene = load("res://scene/BigPlane.tscn")
var my_curves: Array[Curve2D] = []
var lines_data = GameData.lines_data
var route_data

func _ready():
	add_to_group("routes")
	update_hand()

func create_line(airport_a, airport_b):
	var line = Line2D.new()
	add_child(line)
	line.width = 9.0
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
		print("+ точка")
		shapes_list.append(airport_a.my_shape)
		
	if not airport_b.my_shape in shapes_list:
		print("+ точка")
		shapes_list.append(airport_b.my_shape) 
	
	route_data = {
		"route" = self,
		"curve" = curve,
		"start_airport" = airport_a,
		"end_airport" = airport_b,
		"color" = color_name,
		"route_color" = GameData.color_values[color_name]
	}
	
	lines_data[color_name + "_routes"].append(route_data)
	
	if not lines_data["in_" + color_name]:
		if GameData.start_planes > 0:
			spawn_plane(route_data, 0.0, false)
		lines_data["in_" + color_name] = true


@warning_ignore("shadowed_variable")
func spawn_plane(route_data: Dictionary, start_t: float, is_big: bool):
	if not is_big:
		GameData.start_planes -= 1
		var plane = plane_scene.instantiate()
		add_child(plane)
		
		plane.current_route = route_data
		plane.color = route_data["color"]
		plane.t = start_t
		plane.current_speed = 0.0
		
		lines_data[route_data["color"] + "_planes"].append(plane)
		plane.setup_with_route(route_data, start_t)
		
		var CountPlane = get_tree().get_first_node_in_group("countPlane")
		if CountPlane:
			CountPlane.on_plane_spawned()
	else:
		GameData.big_planes -= 1
		var plane = big_plane_scene.instantiate()
		add_child(plane)
		
		plane.current_route = route_data
		plane.color = route_data["color"]
		plane.t = start_t
		
		lines_data[route_data["color"] + "_planes"].append(plane)
		plane.setup_with_route(route_data, start_t)
		
		var CountPlane = get_tree().get_first_node_in_group("countBigPlane")
		if CountPlane:
			CountPlane.on_plane_spawned()


func update_hand():
	if my_curves.is_empty() or typeof(route_data) != TYPE_DICTIONARY:
		return

	var curve = my_curves[0]
	var points = curve.get_baked_points()
	if points.size() < 2:
		return

	var hex_color = lines_data["current hex color"]
	if route_data.has("route_color"):
		hex_color = route_data["route_color"]

	var airports = GameData.lines_data[route_data["color"] + "_airports"]
	if airports.is_empty():
		return
		
	var show_start = (count_connections(route_data["start_airport"], route_data["color"]) == 1)
	var show_end   = (count_connections(route_data["end_airport"], route_data["color"]) == 1)
	var map = get_tree().get_first_node_in_group("maps")

	if show_start:
		var was_hidden = false
		if not is_instance_valid(handle_start):
			handle_start = handle_scene.instantiate()
			add_child(handle_start)
			handle_start.setup(self, true, hex_color)
			was_hidden = true
		elif not handle_start.visible:
			was_hidden = true

		var dir = (points[0] - points[1]).normalized()
		var final_angle = dir.angle()
		
		if map and map.has_method("get_handle_angle"):
			var v_angle = map.get_handle_angle(route_data["start_airport"], route_data["color"])
			if v_angle != -999.0:
				final_angle = v_angle
		
		var final_pos = points[0] + Vector2.from_angle(final_angle) * 35.0
		handle_start.rotation = final_angle
		handle_start.position = final_pos
		handle_start.visible = true

				
		if was_hidden:
			handle_start.animate_appearance(points[0], final_pos, final_angle)
		else:
			handle_start.position = handle_start.position.lerp(final_pos, 0.2)
			handle_start.rotation = lerp_angle(handle_start.rotation, final_angle, 0.2)
		handle_start.visible = true
	else:
		if is_instance_valid(handle_start): handle_start.visible = false

	if show_end:
		var was_hidden = false
		if not is_instance_valid(handle_end):
			handle_end = handle_scene.instantiate()
			add_child(handle_end)
			handle_end.setup(self, false, hex_color)
			was_hidden = true
		elif not handle_end.visible:
			was_hidden = true

		var dir = (points[-1] - points[-2]).normalized()
		var final_angle = dir.angle()
		
		if map and map.has_method("get_handle_angle"):
			var v_angle = map.get_handle_angle(route_data["end_airport"], route_data["color"])
			if v_angle != -999.0:
				final_angle = v_angle
				
		var final_pos = points[-1] + Vector2.from_angle(final_angle) * 35.0
		handle_end.rotation = final_angle
		handle_end.position = final_pos
		handle_end.visible = true

		if was_hidden:
			handle_end.animate_appearance(points[-1], final_pos, final_angle)
		else:
			handle_end.position = handle_end.position.lerp(final_pos, 0.2)
			handle_end.rotation = lerp_angle(handle_end.rotation, final_angle, 0.2)
		handle_end.visible = true
	else:
		if is_instance_valid(handle_end): handle_end.visible = false
		
func count_connections(airport, color) -> int:
	var count = 0
	for r in GameData.lines_data[color + "_routes"]:
		if is_instance_valid(r["route"]) and typeof(r["route"].route_data) == TYPE_DICTIONARY:
			var r_data = r["route"].route_data
			if r_data["start_airport"] == airport:
				count += 1
			if r_data["end_airport"] == airport:
				count += 1
	return count
			
