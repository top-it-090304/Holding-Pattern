extends Node2D

var plane_scene = preload("res://scene/Plane.tscn")

func create_line(airport_a, airport_b):
 ## добавить линию
	var line = Line2D.new()
	add_child(line)
	line.points = [airport_a.position, airport_b.position]
	line.width = 4.0
	line.default_color = Color(0.2, 0.5, 1.0, 0.7)
	line.z_index = -1 ## линия под точкой
 
 ## создать самолет
	var plane = plane_scene.instantiate()
	add_child(plane)
	
	plane.setup(airport_a.position, airport_b.position)
