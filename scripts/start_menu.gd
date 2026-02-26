extends Control

@onready var camera = $Camera2D
@onready var game_scene = $BackgroundGame

# Координаты для перемещения камеры (настройте под свои нужды)
var positions = {
 "main": Vector2(576, 324),
 "settings": Vector2(576, 1000), # Камера едет вниз
 "stats": Vector2(1600, 324)    # Камера едет вправо
}

var target_pos = Vector2(576, 324)

func _ready():
 target_pos = positions["main"]
 camera.position = target_pos

func _process(delta):
 # Плавное перемещение камеры (Lerp)
 camera.position = camera.position.lerp(target_pos, 5.0 * delta)

# Сигналы кнопок
func _on_play_pressed():
 get_tree().change_scene_to_file("res://scene/Main.tscn")

func _on_settings_pressed():
 target_pos = positions["settings"]

func _on_stats_pressed():
 target_pos = positions["stats"]

func _on_back_pressed():
 target_pos = positions["main"]
