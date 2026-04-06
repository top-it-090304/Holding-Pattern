extends Node
var volume = 1.0
var volume_label = "Громко"

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

func apply():
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), volume)

func save_data():
	var file = FileAccess.open("res://user/settings.json", FileAccess.WRITE)
	var data = {
		"volume" : volume,
		"volume_label": volume_label
	}
	file.store_string(JSON.stringify(data))
