extends Control

@onready var camera = $Camera2D
@onready var buttons = [$Play, $Settings, $Stats, $Exit]
@onready var button = [$Back_right, $Back_down]


var positions = {
	"main": Vector2(0, 0),
	"settings": Vector2(0, 1120), ## камера вниз
	"stats": Vector2(1770, 0)    ## камера вправо
}
var anim_speed = 0.12

var target_pos = Vector2(576, 324)

func _ready():
	target_pos = positions["main"]
	camera.position = target_pos
	for btn in buttons:
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(_on_button_hovered.bind(btn))
		btn.mouse_exited.connect(_on_button_unhovered)
	for btn in button:
		btn.pivot_offset = btn.size / 2
		btn.mouse_entered.connect(_on_button_hovered.bind(btn))
		btn.mouse_exited.connect(_on_button_unhovered)

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
		else:
   		## засвет
			tween.tween_property(btn, "scale", scale_others, duration)
			tween.tween_property(btn, "modulate", alpha_faded, duration)
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
