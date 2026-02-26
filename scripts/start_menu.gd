extends Control

@onready var camera = $Camera2D
@onready var game_scene = $BackgroundGame


var positions = {
 "main": Vector2(0, 0),
 "settings": Vector2(0, 1120), ## камера вниз
 "stats": Vector2(1770, 0)    ## камера вправо
}

var target_pos = Vector2(576, 324)

func _ready():
 target_pos = positions["main"]
 camera.position = target_pos

func _process(delta):
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
