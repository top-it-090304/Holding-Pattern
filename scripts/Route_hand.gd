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
		SoundManager.play("station_click")
