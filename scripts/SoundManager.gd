extends Node

var last_play_time = 0

var sounds = {
	"new_week": preload("res://sounds/new_week.ogg"),
	"click_button": preload("res://sounds/click_button.ogg"),
	"click_airport": preload("res://sounds/click_airport.ogg"),
	"draw_rout": preload("res://sounds/draw_rout.ogg"),
	"del_rout": preload("res://sounds/del_rout.ogg"),
	"spawn_passengers": [preload("res://sounds/spawn_passengers_1.ogg"),preload("res://sounds/spawn_passengers_2.ogg")],
	"tap_add_plane": preload("res://sounds/tap_add_plane.ogg"),
	"add_plane": preload("res://sounds/add_plane.ogg")
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func play(sound_name: String, volume: float = 0.0, pitch: float = 1.0):
	var current_time = Time.get_ticks_msec()
	if sound_name == "spawn_passengers" and current_time - last_play_time < 50:
		return
	if sounds.has(sound_name):
		var player = AudioStreamPlayer.new()
		add_child(player)
		
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		
		var sound_res = sounds[sound_name]
		if sound_res is Array:
			player.stream = sound_res.pick_random()
		else:
			player.stream = sound_res
			
		player.volume_db = volume
		player.pitch_scale = pitch * randf_range(0.95, 1.05)
		
		player.play()
		
		player.finished.connect(player.queue_free)
	else:
		print("Звук не найден: ", sound_name)
