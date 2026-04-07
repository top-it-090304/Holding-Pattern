extends Node

var sounds = {
	"new_week": preload("res://sounds/new_week.ogg"),
	"click_button": preload("res://sounds/click_button.ogg"),
	"click_airport": preload("res://sounds/click_airport.ogg"),
	"draw_rout": preload("res://sounds/draw_rout.ogg"),
	"del_rout": preload("res://sounds/del_rout.ogg"),
	"spawn_passengers": preload("res://sounds/spawn_passengers.ogg")
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func play(sound_name: String, volume: float = 0.0, pitch: float = 1.0):
	if sounds.has(sound_name):
		var player = AudioStreamPlayer.new()
		add_child(player)
		
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		
		player.stream = sounds[sound_name]
		player.volume_db = volume
		player.pitch_scale = pitch
		
		player.play()
		
		player.finished.connect(player.queue_free)
	else:
		print("Звук не найден: ", sound_name)
