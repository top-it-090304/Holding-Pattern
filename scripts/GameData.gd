extends Node

var start_planes: int = 8
var max_passengers: int = 10
var current_week = 0

var high_score: int = 0
const SAVE_PATH = "user://savegame.cfg"

enum ShapeType { CIRCLE, SQUARE, TRIANGLE }

var lines_data = {
	"current color" : "yellow",
	"current hex color" : Color(1.0, 0.812, 0.039, 1.0),
	"active colors" : ["yellow", "blue", "red"],
	
	"in_yellow" : false,
	"yellow_routes" : [],
	"yellow_airports" : [],
	"yellow_planes" : [],
	
	"in_blue" : false,
	"blue_routes" : [],
	"blue_airports" : [],
	"blue_planes" : [],
	
	"in_red" : false,
	"red_routes" : [],
	"red_airports" : [],
	"red_planes" : [],
	
	"yellow_shapes" : [],
	"blue_shapes" : [],
	"red_shapes" : []
}

var color_values = {
	"yellow": Color(1.0, 0.812, 0.039, 1.0),
	"blue": Color(0.0, 0.323, 0.983, 1.0),
	"red": Color(1.0, 0.161, 0.118, 1.0)
}



func _ready():
	load_highscore()

func save_highscore(new_score: int):
	if new_score > high_score:
		high_score = new_score
		var config = ConfigFile.new()
		config.set_value("Progression", "high_score", high_score)
		config.save(SAVE_PATH)

func load_highscore():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		high_score = config.get_value("Progression", "high_score", 0)
	else:
		high_score = 0
