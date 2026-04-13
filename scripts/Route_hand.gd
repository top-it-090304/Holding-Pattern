extends Area2D

var route_ref: Node
var is_start: bool = false
var color: Color

signal handle_grabbed(route, is_start)

func setup(route, is_start_point, route_color):
	route_ref = route
	is_start = is_start_point
	color = route_color
	$Sprite2D.modulate = color

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_grabbed.emit(route_ref, is_start)

func animate_appearance(start_pos: Vector2, target_pos: Vector2, dir_angle: float):
	SoundManager.play("draw_rout")
	position = start_pos
	rotation = dir_angle
	scale = Vector2.ZERO
	modulate.a = 0.0
	show()
	
	var tween = create_tween().set_parallel(true)
	
	var anim_time = 0.2
	
	tween.tween_property(self, "position", target_pos, anim_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, anim_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	

	tween.tween_property(self, "modulate:a", 1.0, anim_time * 0.8).set_trans(Tween.TRANS_LINEAR)
