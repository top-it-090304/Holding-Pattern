extends Node2D

@onready var camera = $Camera2D
@onready var buttons = [$Play, $Settings, $Stats, $Exit]
@onready var button = [$Back_right, $Back_down]
@onready var high_score_1 = $LevelSelect/CardsPack/Map_1/Score1
@onready var high_score_2 = $LevelSelect/CardsPack/Map_2/Score2
@onready var high_score_3 = $LevelSelect/CardsPack/Map_3/Score3
@onready var volume_values = ["Без звука", "Тихо", "Средне", "Громко"]
@onready var sound_values = ["Без звука", "Минимум", "Максимум"]
var vibration_true = preload("res://objects/VibrationTrue.png")
var vibration_false = preload("res://objects/VibrationFalse.png")

var positions = {
	"main": Vector2(0, 0),
	"play": Vector2(2800, 1420),
	"settings": Vector2(0, 2320),
	"stats": Vector2(3770, -200)
}


var target_pos = Vector2(576, 324)
var target_rotation: float = 0.0 

func _ready():
	load_settings()
	high_score_1.text = str(GameData.high_scores["level_1"])
	high_score_2.text = str(GameData.high_scores["level_2"])
	high_score_3.text = str(GameData.high_scores["level_3"])
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
	SoundManager.play("click_button")
	target_pos = positions["play"]
	target_rotation = 0.60
	$Back_right.visible = true

func _on_map_1_pressed():
	SoundManager.play("click_button")
	get_tree().change_scene_to_file("res://scene/MAP_IRAN.tscn")
	GameData.lines_data["active colors"] = ["yellow", "blue", "red"]
	GameData.lines_data["inactive colors"] = ["light_blue", "green", "pink", "orange"]
	GameData.lines_data["current color"] = "yellow"
	GameData.start_planes = 3
	GameData.big_airports = 1
	GameData.big_planes = 1
	GameData.current_week = 1
	GameData.lines_data["current hex color"] = Color(1.0, 0.812, 0.039, 1.0)

func _on_map_2_pressed() -> void:
	SoundManager.play("click_button")
	get_tree().change_scene_to_file("res://scene/MAP_SIBIR.tscn")
	GameData.lines_data["active colors"] = ["light_yellow", "light_blue", "bolot"]
	GameData.lines_data["inactive colors"] = ["full_pink", "light_orange", "turquoise", "lavanda"]
	GameData.lines_data["current color"] = "light_yellow"
	GameData.start_planes = 3
	GameData.big_airports = 1
	GameData.big_planes = 1
	GameData.current_week = 1
	GameData.lines_data["current hex color"] = Color(1.0, 0.812, 0.039, 1.0)
	
func _on_map_3_pressed() -> void:
	SoundManager.play("click_button")
	get_tree().change_scene_to_file("res://scene/MAP_AUSTRALIA.tscn")
	GameData.lines_data["active colors"] = ["yellow", "blue", "red"]
	GameData.lines_data["inactive colors"] = ["light_blue", "green", "pink", "orange"]
	GameData.lines_data["current color"] = "yellow"
	GameData.start_planes = 3
	GameData.big_airports = 1
	GameData.big_planes = 1
	GameData.current_week = 1
	GameData.lines_data["current hex color"] = Color(1.0, 0.812, 0.039, 1.0)

func _on_settings_pressed():
	SoundManager.play("click_button")
	target_pos = positions["settings"]
	
func _on_stats_pressed():
	SoundManager.play("click_button")
	target_pos = positions["stats"]

func _on_back_pressed():
	SoundManager.play("click_button")
	target_pos = positions["main"]
	target_rotation = 0.0
	$Back_right.visible = false


func _on_exit_pressed():
	SoundManager.play("click_button")
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
		
  
		if btn == hovered_btn:
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  			## увеличение
			tween.tween_property(btn, "scale", scale_hovered, duration)
			tween.tween_property(btn, "modulate", alpha_full, duration)
	
			
	for btn in button:
		
  
		if btn == hovered_btn:
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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
	
	if Settings.vibration: $SettingsMenu/Vibration.icon = vibration_true
	else: $SettingsMenu/Vibration.icon = vibration_false

func _on_volume_minus_pressed() -> void:
	SoundManager.play("click_button")
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
	SoundManager.play("click_button")
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
	if $SettingsMenu/Volume.text == volume_values[0]: return 0.0
	elif $SettingsMenu/Volume.text == volume_values[1]: return 0.1
	elif $SettingsMenu/Volume.text == volume_values[2]: return 0.5
	elif $SettingsMenu/Volume.text == volume_values[3]: return 1.0


func _on_sound_minus_pressed() -> void:
	SoundManager.play("click_button")
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
	SoundManager.play("click_button")
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
	if $SettingsMenu/Sound.text == sound_values[0]: return 0.0
	elif $SettingsMenu/Sound.text == sound_values[1]: return 0.5
	elif $SettingsMenu/Sound.text == sound_values[2]: return 1.0


func _on_vibration_pressed() -> void:
	if Settings.vibration: 
		Settings.vibration = false
		$SettingsMenu/Vibration.icon = vibration_false
	else:
		Settings.vibration = true
		$SettingsMenu/Vibration.icon = vibration_true
	Settings.apply()
	Settings.save_data()
