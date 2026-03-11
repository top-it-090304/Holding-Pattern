extends Area2D
@onready var sprite = $Point

signal airport_selected(airport)

const Circle = preload("res://objects/point_circle.png")
const Square = preload("res://objects/point_square.png")
const Triangle = preload("res://objects/point_triangle.png")

var my_shape: GameData.ShapeType
var passengers: Array = []

var pulse_radius = 0.0
var pulse_alpha = 1.0
var pulse_color = Color.WHITE

var stroke = false
var stroke_radius = 0.0
var stroke_color = Color.WHITE
var current_max_radius = 10.0

func _ready():
	my_shape = GameData.ShapeType.values().pick_random()
	
	match my_shape:
		GameData.ShapeType.CIRCLE:
			sprite.texture = Circle
		GameData.ShapeType.SQUARE:
			sprite.texture = Square
		GameData.ShapeType.TRIANGLE:
			sprite.texture = Triangle

func _draw():
	if stroke_radius > 3:
		_draw_stroke(stroke_radius, stroke_color, 15.0)
		
	if pulse_radius > 0:
		var p_color = pulse_color
		p_color.a = pulse_alpha
		draw_arc(Vector2.ZERO, pulse_radius, 0, PI*2, 64, p_color, 3.0, true)
		
	_draw_passengers()
	
		
## контур обводка
func _draw_stroke(radius: float, color: Color, line_width: float):
	match my_shape:
		GameData.ShapeType.CIRCLE:
			draw_arc(Vector2.ZERO, radius, 0, PI*2, 64, color, line_width, true)
			
		GameData.ShapeType.SQUARE:
			var rect = Rect2(Vector2(-radius, -radius), Vector2(radius * 2, radius * 2))
			draw_rect(rect, color, false, line_width)
			
		GameData.ShapeType.TRIANGLE:
			var sf = radius * 0.10 
			var points = PackedVector2Array([
				Vector2(0, -12) * sf,
				Vector2(11, 8) * sf,
				Vector2(-11, 8) * sf,
				Vector2(0, -12) * sf
			])
			draw_polyline(points, color, line_width, true)
	
## обводки
func draw_stroke(active: bool):
	stroke_color = GameData.lines_data["current hex color"]
	var tween = create_tween()
	if active and not stroke:
		stroke = true
		tween.tween_property(self, "stroke_radius", current_max_radius, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif not active and stroke:
		stroke = false
		tween.tween_property(self, "stroke_radius", 0.5, 0.5)
		

func activate_pulse():
	pulse_color = GameData.lines_data["current hex color"]
	pulse_radius = 20.0
	pulse_alpha = 1.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "pulse_radius", 50.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "pulse_alpha", 0.0, 0.4)

func _process(_delta):
	if pulse_radius > 0 or stroke_radius > 0:
		queue_redraw()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			activate_pulse()
			airport_selected.emit(self)

## пассажиры
func spawn_passenger():
	var current_shapes = []
	for shape in GameData.ShapeType.values():
		if shape != my_shape:
			current_shapes.append(shape)
	
	var passenger_shape = current_shapes.pick_random()
	passengers.append(passenger_shape)
	queue_redraw()


	
	
func _draw_passengers():
	var start_pos = Vector2(22, -8) 
	var spacing = 13
	var max_in_row = 7
	var passenger_color = Color(0.282, 0.188, 0.188, 1.0)
	var p_size = 5.8
	
	
	for i in range(passengers.size()):
		var shape = passengers[i]
		var row = int(i / max_in_row)
		var col = i % max_in_row
		var pos
		var revers_col
		
		if i == 6:
			start_pos = Vector2(23, -4)
			pos = start_pos + Vector2(col * spacing, row * spacing)
			passenger_color = Color(0.282, 0.188, 0.188, 0.863)
			
		if i > 6:
			start_pos = Vector2(10, -4)
			revers_col = (max_in_row - 1) - col
			pos = start_pos + Vector2(revers_col * spacing, row * spacing)
			passenger_color = Color(0.282, 0.188, 0.188, 0.737)
			
		if i < 6:
			start_pos = Vector2(22, -8)
			pos = start_pos + Vector2(col * spacing, row * spacing)
			
		if i > 12:
			break
		
		
		match shape:
			GameData.ShapeType.CIRCLE:
				draw_circle(pos, p_size, passenger_color, true, 16.0, true)
				
			GameData.ShapeType.SQUARE:
				var rect = Rect2(pos - Vector2(p_size, p_size), Vector2(p_size * 2, p_size * 2))
				draw_rect(rect, passenger_color, true)
				
			GameData.ShapeType.TRIANGLE:
				var side = p_size * 2.2
				var h = side * sqrt(3) / 2
				
				var points = PackedVector2Array([
					pos + Vector2(0, -h/2),
					pos + Vector2(side/2, h/2),
					pos + Vector2(-side/2, h/2)
				])
				draw_colored_polygon(points, passenger_color, PackedVector2Array(), null)
				
				points.append(points[0])
				draw_polyline(points, passenger_color, 0.5, true)
				
