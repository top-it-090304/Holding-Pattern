extends Node
var sound = 1.0
var sound_label = "Максимум"
var volume = 1.0
var volume_label = "Громко"
var vibration: bool = true

func _ready():
	load_data()
	apply()

func load_data():
	if not FileAccess.file_exists("res://user/settings.json"):
		return
	var file = FileAccess.open("res://user/settings.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	volume = data.get("volume", 1.0)
	volume_label = data.get("volume_label", "Громко")
	sound = data.get("sound", 1.0)
	sound_label = data.get("sound_label", "Максимум")
	vibration = data.get("vibration", true)

func apply():
	if sound == 0.0: AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), 0.0)
	elif sound == 0.5:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), 0.0)
	elif sound == 1.0:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), 1.0)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), volume)


func save_data():
	var file = FileAccess.open("res://user/settings.json", FileAccess.WRITE)
	var data = {
		"volume" : volume,
		"volume_label": volume_label,
		"sound": sound,
		"sound_label": sound_label,
		"vibration": vibration
	}
	file.store_string(JSON.stringify(data))
