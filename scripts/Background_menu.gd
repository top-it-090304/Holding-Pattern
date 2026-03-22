extends Node2D

var airport_scene = preload("res://scene/Airport.tscn")
var route_scene = preload("res://scene/Route.tscn")

func _process(_delta):
	var planes = get_tree().get_nodes_in_group("planes")
	for p in planes:
		if p.scale == Vector2(1, 1):
			p.scale = Vector2(5, 5)
			p.target_speed = 60.0

func _ready():
	setup_menu_traffic()

func setup_menu_traffic():
	var points = $Points.get_children()
	if points.size() < 2: return
	
	# Создаем два невидимых аэропорта
	var air1 = _create_hidden_airport(points[0].position)
	var air2 = _create_hidden_airport(points[1].position)
	var air3 = _create_hidden_airport(points[2].position)
	var air4 = _create_hidden_airport(points[3].position)
	var air5 = _create_hidden_airport(points[4].position)
	var air6 = _create_hidden_airport(points[5].position)
	
	
	air1.forced_shape = GameData.ShapeType.CIRCLE
	air2.forced_shape = GameData.ShapeType.SQUARE
	
	var route = route_scene.instantiate()
	add_child(route)
	

	GameData.lines_data["current hex color"] = Color(1.0, 0.804, 0.0, 1.0)
	route.create_line(air1, air2)
	
	GameData.lines_data["current hex color"] = Color(1.0, 0.804, 0.0, 1.0)
	route.create_line(air3, air4)
	
	GameData.lines_data["current hex color"] = Color(1.0, 0.804, 0.0, 1.0)
	route.create_line(air5, air6)

func _create_hidden_airport(pos):
	var a = airport_scene.instantiate()
	a.position = pos
	add_child(a)
	a.modulate.a = 0 
	a.process_mode = Node.PROCESS_MODE_DISABLED 
	return a
