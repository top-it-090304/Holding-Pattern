extends Node

var passengers: Array = []
var new_passenger_scale: float = 1.0

func spawn_passenger(my_shape):
	var current_shapes = []
	for shape in GameData.ShapeType.values():
		if shape != my_shape:
			current_shapes.append(shape)
	
	var passenger_shape = current_shapes.pick_random()
	passengers.append(passenger_shape)
	
	new_passenger_scale = 0.0
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_method(_animation_spawn_pass_, 0.0, 1.0, 0.3)

func _animation_spawn_pass_(value: float):
	new_passenger_scale = value


func draw_passengers(drawer: Node2D):
	var start_pos = Vector2(22, -8)
	var spacing = 14.5
	var max_in_row = 7
	var passenger_color = Color(0.173, 0.157, 0.173, 1.0)
	var p_size = 7.0
	
	for i in range(passengers.size()):
		var shape = passengers[i]
		@warning_ignore("integer_division")
		var row = int(i / max_in_row)
		var col = i % max_in_row
		var pos
		var revers_col
		
		var current_scale = 1.0
		if i == passengers.size() - 1:
			current_scale = new_passenger_scale
		
		if i == 6:
			start_pos = Vector2(31, -6)
			pos = start_pos + Vector2(col * spacing, row * spacing)
			passenger_color.a = 0.86
		
		elif i > 6:
			start_pos = Vector2(15, -9)
			revers_col = (max_in_row - 1) - col
			pos = start_pos + Vector2(revers_col * spacing, row * spacing)
			passenger_color.a = 0.73
		
		else:
			start_pos = Vector2(30, -13)
			pos = start_pos + Vector2(col * spacing, row * spacing)
		
		if i > 12:
			break
		
		match shape:
			GameData.ShapeType.CIRCLE:
				drawer.draw_circle(pos, p_size * current_scale, passenger_color)
				
			GameData.ShapeType.SQUARE:
				var s = p_size * current_scale
				var rect = Rect2(pos - Vector2(s, s), Vector2(s * 2, s * 2))
				drawer.draw_rect(rect, passenger_color, true)
				
			GameData.ShapeType.TRIANGLE:
				var size = p_size * current_scale * 2.2
				var h = size * sqrt(3) / 2
				
				var points = PackedVector2Array([
					pos + Vector2(0, -h/2),
					pos + Vector2(size/2, h/2),
					pos + Vector2(-size/2, h/2)
				])
				
				drawer.draw_colored_polygon(points, passenger_color)
				
				
