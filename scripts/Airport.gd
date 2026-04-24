extends Area2D
@onready var sprite = $Point
@onready var passenger_manager = get_node_or_null("PassengerManager")

var CLICK_RADIUS : float = 40.0

signal airport_selected(airport)
signal end_game(airport)

const Circle = preload("res://objects/point_circle.png")
const Square = preload("res://objects/point_square.png")
const Triangle = preload("res://objects/point_triangle.png")

var my_shape: GameData.ShapeType
var forced_shape = null

var max_time: float = 45.0
var current_time: float = 0.0
var is_failed: bool = false

var pulse_radius = 0.0
var pulse_alpha = 1.0
var pulse_color = Color.WHITE


var stroke = false
var stroke_radius = 0.0
var stroke_color = Color.WHITE
var current_max_radius = 15.0

var lines_data = GameData.lines_data


func _ready():
	if passenger_manager == null:
		passenger_manager = preload("res://scripts/PassengerManager.gd").new()
		add_child(passenger_manager)
	
	if forced_shape != null:
		my_shape = forced_shape
	else:
		my_shape = GameData.ShapeType.values().pick_random()
	
	match my_shape:
		GameData.ShapeType.CIRCLE:
			sprite.texture = Circle
		GameData.ShapeType.SQUARE:
			sprite.texture = Square
		GameData.ShapeType.TRIANGLE:
			sprite.texture = Triangle
	
	spawn_animation()
	
func _process(delta):
	
	sprite.scale = Vector2(0.7, 0.7)
	if is_failed: return
	if passenger_manager.passengers.size() >= GameData.max_passengers:
		current_time += delta
		queue_redraw()
	
		if current_time >= max_time:
			is_failed = true
			end_game.emit(self)
			
	elif current_time > 0:
		current_time -= delta * 2.0 
		current_time = max(0.0, current_time)
		queue_redraw()
		
	if pulse_radius > 0 or stroke_radius > 0:
		queue_redraw()


func _draw():
	if stroke_radius > 11:
		_draw_stroke(stroke_radius, stroke_color, 28.0)
		
	if pulse_radius and pulse_alpha > 0:
		var color_with_alpha = pulse_color
		color_with_alpha.a = pulse_alpha * 0.5
		
		draw_circle(Vector2.ZERO, pulse_radius, color_with_alpha, 64)
		
	passenger_manager.draw_passengers(self)
	
	if current_time > 0:
		var progress = current_time / max_time
		var danger_radius = 27.0
		var danger_color = Color(0.553, 0.553, 0.553, 0.78)
		draw_arc(Vector2.ZERO, danger_radius, -PI/2, -PI/2 + (TAU * progress), 64, danger_color, 32.5, true)
		

func spawn_animation():
	SoundManager.play("spawn_airport")
	sprite.scale = Vector2.ZERO
	var tween_pop = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_pop.tween_property(sprite, "scale", Vector2(0.7, 0.7), 1.0)
	
	pulse_color = Color(0.502, 0.502, 0.502, 0.522)
	pulse_alpha = 1.0
	pulse_radius = 0.0
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_method(_animation_spawn_, 0.0, 45.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "pulse_alpha", 0.0, 0.8)
	
func _animation_spawn_(value: float):
	pulse_radius = value
	queue_redraw()
	
func animation_pulse(new_radius: float):
	pulse_radius = new_radius
	queue_redraw()
	
## контур обводка
func _draw_stroke(radius: float, color: Color, line_width: float):
	match my_shape:
		GameData.ShapeType.CIRCLE:
			draw_arc(Vector2.ZERO, radius, 0, PI*2, 64, color, line_width, true)
			
		GameData.ShapeType.SQUARE:
			var rect = Rect2(Vector2(-radius, -radius), Vector2(radius * 2, radius * 2))
			draw_rect(rect, color, false, line_width)
			
		GameData.ShapeType.TRIANGLE:
			var sf = radius * 0.10 * 0.7
			var points = PackedVector2Array([
				Vector2(0, -12) * sf,
				Vector2(11, 8) * sf,
				Vector2(-11, 8) * sf,
				Vector2(0, -12) * sf
			])
			draw_polyline(points, color, line_width, true)
			
	
func toggle_stroke(active: bool, color: Color = Color.WHITE):
	stroke_color = color
	var tween = create_tween()
	var target_r = 10.0 if active else 0.0
	
	tween.tween_property(self, "stroke_radius", target_r, 0.15).set_trans(Tween.TRANS_SINE)
	
	
## обводки
func draw_stroke(active: bool):
	stroke_color = GameData.lines_data["current hex color"]
	
	if active and not stroke:
		var tween = create_tween()
		stroke = true
		tween.tween_property(self, "stroke_radius", current_max_radius, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif not active and stroke:
		var tween = create_tween()
		stroke = false
		tween.tween_property(self, "stroke_radius", 0.5, 0.5)
		

func activate_pulse():
	pulse_color = GameData.lines_data["current hex color"]
	pulse_radius = 20.0
	pulse_alpha = 1.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "pulse_radius", 50.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "pulse_alpha", 0.0, 0.4)

## пассажиры
func spawn_passenger():
	passenger_manager.spawn_passenger(my_shape)
	queue_redraw()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var permision = false
		for color in lines_data["active colors"]:
			if not lines_data[color + "_routes"]:
				lines_data["current color"] = color
				lines_data["current hex color"] = GameData.color_values[color]
				permision = true
				break
		if permision:
			activate_pulse()
			airport_selected.emit(self)
