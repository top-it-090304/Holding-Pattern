extends Area2D

signal airport_selected(airport)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Click")
			airport_selected.emit(self)
