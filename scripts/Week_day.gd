extends Label

var day_time: float = 20.27
var days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
var current_day_index = 0

func _ready():
	_update_day_text()
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = day_time
	timer.timeout.connect(_on_day_timeout)
	timer.start()

func _on_day_timeout():
	current_day_index += 1
	
	if current_day_index >= days.size():
		current_day_index = 0
	
	_update_day_text()
	_animate_week()

func _update_day_text():
	text = days[current_day_index]

func _animate_week():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale = Vector2(1.2, 1.2)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)
