extends Node

var sounds = {
	"new_week": preload("res://sounds/new_week.ogg"),
	
}

func play(sound_name: String, volume: float = 0.0, pitch: float = 1.0):
	print("звук")
	if sounds.has(sound_name):
		var player = AudioStreamPlayer.new()
		add_child(player)
		
		player.stream = sounds[sound_name]
		player.volume_db = volume
		player.pitch_scale = pitch
		
		player.play()
		
		player.finished.connect(player.queue_free)
	else:
		print("Звук не найден: ", sound_name)
