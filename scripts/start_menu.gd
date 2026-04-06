extends Node2D

@onready var camera = $Camera2D
@onready var buttons = [$Play, $Settings, $Stats, $Exit]
@onready var button = [$Back_right, $Back_down]
@onready var high_score_1 = $LevelSelect/CardsPack/Map_1/Score1
@onready var high_score_2 = $LevelSelect/CardsPack/Map_2/Score2
@onready var volume_values = ["Без звука", "Тихо", "Средне", "Громко"]
@onready var sound_values = ["Без звука", "Минимум", "Максимум"]

var positions = {
	"main": Vector2(0, 0),
	"play": Vector2(2800, 1420),
	"settings": Vector2(0, 1620),
	"stats": Vector2(3770, -200)
}


var target_pos = Vector2(576, 324)
var target_rotation: float = 0.0 

func _ready():
	load_settings()
	high_score_1.text = str(GameData.high_score)
	target_pos = positions["main"]
	camera.position = target_pos
	target_rotation = 0.0
	for btn in buttons:
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(_on_button_hovered.bind(btn))
		btn.mouse_exited.connect(_on_button_unhovered)
	for btn in button:
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(_on_button_hovered.bind(btn))
		btn.mouse_exited.connect(_on_button_unhovered)

func _process(delta):
	camera.position = camera.position.lerp(target_pos, 3.5 * delta)
	camera.rotation = lerp_angle(camera.rotation, target_rotation, 3.0 * delta)

## Сигналы кнопок
func _on_play_pressed():
	target_pos = positions["play"]
	target_rotation = 0.60
	$Back_right.visible = true

func _on_map_1_pressed():
	get_tree().change_scene_to_file("res://scene/MAP_IRAN.tscn")
	
func _on_map_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/MAP_SIBIR.tscn")

func _on_settings_pressed():
	target_pos = positions["settings"]
	
func _on_stats_pressed():
	target_pos = positions["stats"]

func _on_back_pressed():
	target_pos = positions["main"]
	target_rotation = 0.0
	$Back_right.visible = false


func _on_exit_pressed():
	get_tree().quit()


## анимация кнопок
var hover_scale = Vector2(1.2, 1.2)
var normal_scale = Vector2(1.0, 1.0)
var faded_alpha = Color(1, 1, 1, 0.3)
var normal_alpha = Color(1, 1, 1, 1.0)



## анимация кнопок
var scale_hovered = Vector2(1.15, 1.15)
var scale_others = Vector2(0.85, 0.85)
var scale_normal = Vector2(1.0, 1.0)

var alpha_faded = Color(1, 1, 1, 0.4)
var alpha_full = Color(1, 1, 1, 1.0)

var duration = 0.12

 

func _on_button_hovered(hovered_btn):
	for btn in buttons:
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  
		if btn == hovered_btn:
  			## увеличение
			tween.tween_property(btn, "scale", scale_hovered, duration)
			tween.tween_property(btn, "modulate", alpha_full, duration)
	
			
	for btn in button:
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  
		if btn == hovered_btn:
   		## увеличение
			tween.tween_property(btn, "scale", scale_hovered, duration)
			tween.tween_property(btn, "modulate", alpha_full, duration)

func _on_button_unhovered():
 
	for btn in buttons:
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", scale_normal, duration)
		tween.tween_property(btn, "modulate", alpha_full, duration)

	for btn in button:
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", scale_normal, duration)
		tween.tween_property(btn, "modulate", alpha_full, duration)

func load_settings():
	$SettingsMenu/Volume.text = Settings.volume_label
	if Settings.volume_label == volume_values[0]:
		$SettingsMenu/VolumeMinus.disabled = true
	else: $SettingsMenu/VolumeMinus.disabled = false
	if Settings.volume_label == volume_values[-1]:
		$SettingsMenu/VolumePlus.disabled = true
	else: $SettingsMenu/VolumePlus.disabled = false
	
	$SettingsMenu/Sound.text = Settings.sound_label
	if Settings.sound_label == sound_values[0]:
		$SettingsMenu/SoundMinus.disabled = true
	else: $SettingsMenu/SoundMinus.disabled = false
	if Settings.sound_label == sound_values[-1]:
		$SettingsMenu/SoundPlus.disabled = true
	else: $SettingsMenu/SoundPlus.disabled = false

func _on_volume_minus_pressed() -> void:
	$SettingsMenu/Volume.text = volume_values[volume_values.find($SettingsMenu/Volume.text) - 1]
	if $SettingsMenu/Volume.text == volume_values[0]:
		$SettingsMenu/VolumeMinus.disabled = true
	if $SettingsMenu/Volume.text == volume_values[2]:
		$SettingsMenu/VolumePlus.disabled = false
	Settings.volume = convert_volume()
	Settings.volume_label = $SettingsMenu/Volume.text
	Settings.apply()
	Settings.save_data()

func _on_volume_plus_pressed() -> void:
	$SettingsMenu/Volume.text = volume_values[volume_values.find($SettingsMenu/Volume.text) + 1]
	if $SettingsMenu/Volume.text == volume_values[-1]:
		$SettingsMenu/VolumePlus.disabled = true
	if $SettingsMenu/Volume.text == volume_values[1]:
		$SettingsMenu/VolumeMinus.disabled = false
	Settings.volume = convert_volume()
	Settings.volume_label = $SettingsMenu/Volume.text
	Settings.apply()
	Settings.save_data()

func convert_volume():
	var volume
	if $SettingsMenu/Volume.text == volume_values[0]: volume = 0.0
	elif $SettingsMenu/Volume.text == volume_values[1]: volume = 0.33
	elif $SettingsMenu/Volume.text == volume_values[2]: volume = 0.67
	elif $SettingsMenu/Volume.text == volume_values[3]: volume = 1.0
	return volume


func _on_sound_minus_pressed() -> void:
	$SettingsMenu/Sound.text = sound_values[sound_values.find($SettingsMenu/Sound.text) - 1]
	if $SettingsMenu/Sound.text == sound_values[0]:
		$SettingsMenu/SoundMinus.disabled = true
	if $SettingsMenu/Sound.text == sound_values[1]:
		$SettingsMenu/SoundPlus.disabled = false
	Settings.sound = convert_sound()
	Settings.sound_label = $SettingsMenu/Sound.text
	Settings.apply()
	Settings.save_data()

func _on_sound_plus_pressed() -> void:
	$SettingsMenu/Sound.text = sound_values[sound_values.find($SettingsMenu/Sound.text) + 1]
	if $SettingsMenu/Sound.text == sound_values[-1]:
		$SettingsMenu/SoundPlus.disabled = true
	if $SettingsMenu/Sound.text == sound_values[1]:
		$SettingsMenu/SoundMinus.disabled = false
	Settings.sound = convert_sound()
	Settings.sound_label = $SettingsMenu/Sound.text
	Settings.apply()
	Settings.save_data()

func convert_sound():
	var sound
	if $SettingsMenu/Sound.text == sound_values[0]: sound = 0.0
	elif $SettingsMenu/Sound.text == sound_values[1]: sound = 0.5
	elif $SettingsMenu/Sound.text == sound_values[2]: sound = 1.0
	return sound
