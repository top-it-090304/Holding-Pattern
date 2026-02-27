extends Node2D

var airport_scene = load("res://scene/Airport.tscn")
var route_scene = load("res://scene/Route.tscn")

@onready var spawn_points_node := $AirportSpawn
var airport_points: Array[Vector2] = []

var selected_airport = null
var is_drawing: bool = false
var pred_line: Line2D

var line_color = Color(1, 1, 0, 0.7)
signal color_changed(new_color)

# Словари для хранения лимитов
var color_limits = {
	"yellow": {"lines": 3, "planes": 2, "current_lines": 0, "current_planes": 0},
	"blue": {"lines": 3, "planes": 2, "current_lines": 0, "current_planes": 0},
	"red": {"lines": 3, "planes": 2, "current_lines": 0, "current_planes": 0}
}

# Текущий цвет в виде строки
var current_color_name = "yellow"

func _ready():
	pred_line = Line2D.new()
	pred_line.width = 3.0
	pred_line.default_color = Color(1, 1, 1, 0.5)
	pred_line.z_index = 10
	add_child(pred_line)
 
	for child in spawn_points_node.get_children():
		if child is Marker2D:
			airport_points.append(child.global_position)
	airport_points.shuffle()
 
	for i in range(3):
		spawn_airport()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			stop_draw()

func _process(_delta):
	if is_drawing and selected_airport:
		line_draw(selected_airport.global_position, get_global_mouse_position())
		check_airport()

func line_draw(p0: Vector2, p2: Vector2):
	var curve = Curve2D.new()
	var mid = (p0 + p2) / 2
	var offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	var control_point = (mid + offset) - p0
 
	curve.add_point(p0, Vector2.ZERO, control_point)
	curve.add_point(p2)
	pred_line.points = curve.get_baked_points()

func check_airport():
	var mouse_pos = get_global_mouse_position()
	for airport in get_tree().get_nodes_in_group("airports"):
		if airport != selected_airport and airport.global_position.distance_to(mouse_pos) < 50:
			# Проверяем, можно ли создать линию текущего цвета
			if can_create_line(current_color_name):
				create_route(selected_airport, airport)
				selected_airport = airport
			else:
				# Визуально показываем, что нельзя создать линию
				print("Достигнут лимит линий для цвета ", current_color_name)
				stop_draw()

func can_create_line(color_name: String) -> bool:
	var limit_data = color_limits[color_name]
	return limit_data["current_lines"] < limit_data["lines"]

func can_create_plane(color_name: String) -> bool:
	var limit_data = color_limits[color_name]
	return limit_data["current_planes"] < limit_data["planes"]

func create_route(a, b):
	var route = route_scene.instantiate()
	add_child(route)
	route.create_line(a, b, line_color, current_color_name)
	
	# Увеличиваем счётчик линий
	color_limits[current_color_name]["current_lines"] += 1
	
	# Обновляем UI (если есть)
	update_ui()

func stop_draw():
	selected_airport = null
	is_drawing = false
	pred_line.clear_points()

func spawn_airport():
	if airport_points.is_empty(): return
	var inst = airport_scene.instantiate()
	inst.position = airport_points.pop_back()
	inst.add_to_group("airports")
	inst.airport_selected.connect(_on_airport_selected)
	add_child(inst)

func _on_airport_selected(airport):
	selected_airport = airport
	is_drawing = true

## кнопки
func _on_yb_toggled(_t):
	line_color = Color(1, 1, 0, 0.7)
	current_color_name = "yellow"
	color_changed.emit(line_color)
	update_ui()

func _on_bb_toggled(_t):
	line_color = Color(0, 0, 1, 0.7)
	current_color_name = "blue"
	color_changed.emit(line_color)
	update_ui()

func _on_rb_toggled(_t):
	line_color = Color(1, 0, 0, 0.7)
	current_color_name = "red"
	color_changed.emit(line_color)
	update_ui()

func _on_spawn_timer_timeout():
	spawn_airport()

# Функция для обновления UI (если есть)
func update_ui():
	var limit_data = color_limits[current_color_name]
	print("Цвет: ", current_color_name, 
		  ", Линии: ", limit_data["current_lines"], "/", limit_data["lines"],
		  ", Самолёты: ", limit_data["current_planes"], "/", limit_data["planes"])

# Функция для добавления самолёта (вызывается из Route.gd)
func add_plane_for_color(color_name: String):
	if can_create_plane(color_name):
		color_limits[color_name]["current_planes"] += 1
		update_ui()
		return true
	else:
		print("Достигнут лимит самолётов для цвета ", color_name)
		return false
