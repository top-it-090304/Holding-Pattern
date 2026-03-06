extends Area2D

signal airport_selected(airport)

var pulse_radius = 0.0
var pulse_alpha = 1.0
var pulse_color = Color.WHITE

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			activate_pulse()
			airport_selected.emit(self)

func activate_pulse():
	pulse_color = GameData.lines_data["current hex color"]
	play_pulse_effect()

func play_pulse_effect():
	pulse_radius = 20.0
	pulse_alpha = 1.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "pulse_radius", 50.0, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "pulse_alpha", 0.0, 0.4)

func _process(_delta):
	if pulse_radius > 0:
		queue_redraw()

func _draw():
	if pulse_radius > 0:
		var draw_color = pulse_color
		draw_color.a = pulse_alpha
		draw_arc(Vector2.ZERO, pulse_radius, 0, TAU, 64, draw_color, 3.0, true)
