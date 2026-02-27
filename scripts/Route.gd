extends Node2D

var plane_scene = load("res://scene/Plane.tscn")
@onready var main_script = $"/root/Main"

var line_color_name = "yellow"  # Добавляем переменную для хранения имени цвета

func _ready():
	main_script.color_changed.connect(create_line)

func create_line(airport_a, airport_b, new_color, color_name = "yellow"):
	
	# Проверяем, можно ли создать линию (на всякий случай)
	if not main_script.can_create_line(color_name):
		print("Нельзя создать линию, достигнут лимит")
		queue_free()  # Удаляем маршрут, если лимит превышен
		return
	
	line_color_name = color_name  # Сохраняем имя цвета
	
	var line = Line2D.new()
	add_child(line)
	line.width = 4.0
	line.default_color = new_color
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
 
	if plane_scene:
		# Проверяем, можно ли создать самолёт
		if main_script.add_plane_for_color(color_name):
			var plane = plane_scene.instantiate()
			add_child(plane)
			plane.setup_with_curve(curve)
			plane.color_name = color_name  # Передаём цвет самолёту
		else:
			print("Нельзя создать самолёт, лимит достигнут")
