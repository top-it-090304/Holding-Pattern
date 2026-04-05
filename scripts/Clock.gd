extends Control

@onready var arrow = $Arrow
@onready var circle = $Circle
@onready var riski = $Riski
@onready var day_label = $WeekDay

var day_time: float = 10.0
var current_time: float = 0.0
var is_day = true
var full_day = false

var night_bg = Color(0.18, 0.157, 0.18, 1.0)
var night_el = Color(0.647, 0.647, 0.647, 1.0)
var day_bg = Color(0.822, 0.822, 0.822, 1.0)
var day_el = Color(0.165, 0.149, 0.165, 1.0)

func _process(delta: float):
	current_time += delta
	if current_time >= day_time:
		current_time = 0.0
		full_day = true
		
		is_day = not is_day
		
	var rotation_pct = current_time / day_time
	arrow.rotation_degrees = rotation_pct * 360.0
	
	if is_day:
		_transition_clock_theme(day_bg, day_el, delta)
		
	else:
		_transition_clock_theme(night_bg, night_el, delta)

func _transition_clock_theme(target_bg: Color, target_elements: Color, delta: float):
	circle.modulate = circle.modulate.lerp(target_bg, delta * 3.0)
	riski.modulate = riski.modulate.lerp(target_elements, delta * 3.0)
	arrow.modulate = arrow.modulate.lerp(target_elements, delta * 3.0)
