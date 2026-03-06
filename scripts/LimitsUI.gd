extends Control

@onready var main = $"/root/Main"
@onready var yellow_label = $YellowLabel
@onready var blue_label = $BlueLabel
@onready var red_label = $RedLabel

func _ready():
	# Подключаемся к сигналу изменения цвета для обновления UI
	main.color_changed.connect(_on_color_changed)
	update_all_limits()

func _on_color_changed(new_color):
	update_all_limits()

func update_all_limits():
	update_color_limit("yellow", yellow_label)
	update_color_limit("blue", blue_label)
	update_color_limit("red", red_label)

func update_color_limit(color_name: String, label: Label):
	var data = main.color_limits[color_name]
	label.text = "%s: Линии %d/%d, Самолёты %d/%d" % [
		color_name.capitalize(),
		data["current_lines"],
		data["lines"],
		data["current_planes"],
		data["planes"]
	]
	
	# Подсвечиваем текущий цвет
	if main.current_color_name == color_name:
		label.modulate = Color.WHITE
	else:
		label.modulate = Color.GRAY
