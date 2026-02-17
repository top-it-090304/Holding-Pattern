extends Node2D

# Используем load для надежности, если export выдает null
var airport_scene = load("res://scene/Airport.tscn")
var route_scene = load("res://scene/Route.tscn")

@onready var spawn_points_node := $AirportSpawn
var airport_points: Array[Vector2] = []

var selected_airport = null
var is_drawing: bool = false
var pred_line: Line2D

func _ready():
	# Настройка визуальной линии, которую тянет игрок
	pred_line = Line2D.new()
	pred_line.width = 3.0
	pred_line.default_color = Color(1, 1, 1, 0.5)
	pred_line.z_index = 10
	add_child(pred_line)
	
	# Сбор точек из маркеров
	for child in spawn_points_node.get_children():
		if child is Marker2D:
			airport_points.append(child.global_position)
	
	airport_points.shuffle()
	
	# Первые аэропорты
	for i in range(3):
		spawn_airport()

func _input(event):
	# Если отпустили кнопку — сбрасываем рисование
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_stop_drawing()

func _process(_delta):
	if is_drawing and selected_airport:
		pred_line.clear_points()
		pred_line.add_point(selected_airport.position)
		pred_line.add_point(get_global_mouse_position())
		
		# Проверяем, коснулись ли мы другого аэропорта при протягивании
		_check_hover_connection()

func _check_hover_connection():
	var mouse_pos = get_global_mouse_position()
	# Ищем аэропорты в группе "airports"
	for airport in get_tree().get_nodes_in_group("airports"):
		if airport != selected_airport and airport.global_position.distance_to(mouse_pos) < 50:
			_create_route(selected_airport, airport)
			# В Mini Metro линия продолжается от нового аэропорта
			selected_airport = airport 

func _create_route(a, b):
	if route_scene:
		var route = route_scene.instantiate()
		add_child(route)
		route.create_line(a, b)

func _stop_drawing():
	selected_airport = null
	is_drawing = false
	pred_line.clear_points()

func spawn_airport():
	if airport_points.is_empty() or not airport_scene: return
	
	var inst = airport_scene.instantiate()
	inst.position = airport_points.pop_back()
	# Добавляем в группу, чтобы _check_hover_connection мог их найти
	inst.add_to_group("airports") 
	inst.airport_selected.connect(_on_airport_selected)
	add_child(inst)

func _on_airport_selected(airport):
	selected_airport = airport
	is_drawing = true
