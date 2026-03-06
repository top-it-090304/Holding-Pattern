extends Label

func _ready():
	add_to_group("countPlane")
	update_counter()
	
func update_counter():
	if GameData.start_planes > 0:
		self_modulate = Color(0.2, 0.176, 0.2, 1.0)
	else:
		self_modulate = Color(0.639, 0.62, 0.612, 1.0)
	text = str(GameData.start_planes)

func on_plane_spawned():
	update_counter()

func add_bonus_planes(bonus):
	GameData.start_planes += bonus
	update_counter()
