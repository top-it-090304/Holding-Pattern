extends Node2D

@export var plane_speed: float = 250.0

func _ready():
	await get_tree().create_timer(0.1).timeout
	
	var points = $Points.get_children()
	if points.size() < 2: return
	_create_menu_route(points[0].global_position, points[1].global_position, Color(0.1, 0.5, 1.0, 0.8), 50.0)  # Синяя дуга
	
	if points.size() >= 3:
		_create_menu_route(points[2].global_position, points[3].global_position, Color(1.0, 0.2, 0.2, 0.8), -80.0)
		
		_create_menu_route(points[3].global_position, points[4].global_position, Color(1.0, 0.2, 0.2, 0.8), -80.0) # Красная дуга (выгнута в другую сторону)
	if points.size() >= 4:
		_create_menu_route(points[5].global_position, points[6].global_position, Color(1.0, 0.8, 0.1, 0.8), -150.0)   # Желтая ПРЯМАЯ (высота = 0)

func _create_menu_route(start_pos: Vector2, end_pos: Vector2, route_color: Color, arc_height: float = 0.0):
	
	var points_array = PackedVector2Array()
	
	if arc_height == 0.0:
		points_array.append(start_pos)
		points_array.append(end_pos)
	else:
		# Кривая Безье (плавная дуга)
		var mid = (start_pos + end_pos) / 2.0
		var dir = (end_pos - start_pos).normalized()
		var normal = Vector2(-dir.y, dir.x)
		var control = mid + normal * arc_height*3
		
		var resolution = 64
		for i in range(resolution + 1):
			var t = float(i) / resolution
			var q0 = start_pos.lerp(control, t)
			var q1 = control.lerp(end_pos, t)
			points_array.append(q0.lerp(q1, t))
	
	var line = Line2D.new()
	line.points = points_array
	line.width = 12.0
	line.default_color = route_color
	add_child(line)
	

	var plane = Sprite2D.new()
	plane.texture = load("res://objects/Fly.png")
	plane.scale = Vector2(1.5, 1.5)
	plane.modulate = route_color
	
	plane.set_script(preload("res://scripts/Menu_plane.gd"))
	add_child(plane)
	
	plane.start_flight(points_array, plane_speed)
