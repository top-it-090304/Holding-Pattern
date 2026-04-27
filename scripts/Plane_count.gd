extends Label

@onready var add_plane_btn = $"../AddPlane"
@onready var add_plane_count = $"."

func _ready():
	add_to_group("countPlane")


func add_bonus_planes():
	GameData.start_planes += 1
	_animate_bonus_plane()
	
	
func _animate_bonus_plane():
	add_plane_btn.pivot_offset = add_plane_btn.size / 2
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(add_plane_btn, "scale", Vector2(1.3, 1.3), 0.15)
	
	tween.tween_property(add_plane_btn, "scale", Vector2(1.0, 1.0), 0.25)

	add_plane_count.pivot_offset = add_plane_count.size / 2
	var tween_count = create_tween()
	
	tween_count.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween_count.tween_property(add_plane_count, "scale", Vector2(1.2, 1.2), 0.15)
	
	tween_count.tween_property(add_plane_count, "scale", Vector2(1.0, 1.0), 0.25)
