extends Node

var start_planes: int = 3
var big_planes: int = 1
var big_airports: int = 1
var max_passengers: int = 6
var big_max_passengers: int = 10
var current_week: int = 1

var high_score: int = 0
const SAVE_PATH = "user://savegame.cfg"

enum ShapeType { CIRCLE, SQUARE, TRIANGLE }

var lines_data = {
	"current color" : "yellow",
	"current hex color" : Color(1.0, 0.812, 0.039, 1.0),
	"active colors" : ["yellow", "blue", "red"],
	"inactive colors" : ["light_blue", "green", "pink", "orange"],
	
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
	
	"in_light_blue" : false,
	"light_blue_routes" : [],
	"light_blue_airports" : [],
	"light_blue_planes" : [],
	
	"in_green" : false,
	"green_routes" : [],
	"green_airports" : [],
	"green_planes" : [],
	
	"in_pink" : false,
	"pink_routes" : [],
	"pink_airports" : [],
	"pink_planes" : [],
	
	"in_orange" : false,
	"orange_routes" : [],
	"orange_airports" : [],
	"orange_planes" : [],
	
	"in_light_yellow" : false,
	"light_yellow_routes" : [],
	"light_yellow_airports" : [],
	"light_yellow_planes" : [],
	
	"in_bolot" : false,
	"bolot_routes" : [],
	"bolot_airports" : [],
	"bolot_planes" : [],
	
	"in_full_pink" : false,
	"full_pink_routes" : [],
	"full_pink_airports" : [],
	"full_pink_planes" : [],
	
	"in_lavanda" : false,
	"lavanda_routes" : [],
	"lavanda_airports" : [],
	"lavanda_planes" : [],
	
	"in_light_orange" : false,
	"light_orange_routes" : [],
	"light_orange_airports" : [],
	"light_orange_planes" : [],
	
	"in_turquoise" : false,
	"turquoise_routes" : [],
	"turquoise_airports" : [],
	"turquoise_planes" : [],
	
	"yellow_shapes" : [],
	"blue_shapes" : [],
	"red_shapes" : [],
	"light_blue_shapes" : [],
	"green_shapes" : [],
	"pink_shapes" : [],
	"orange_shapes" : [],
	"light_yellow_shapes" : [],
	"bolot_shapes" : [],
	"full_pink_shapes" : [],
	"lavanda_shapes" : [],
	"light_orange_shapes" : [],
	"turquoise_shapes" : [],
}

var color_values = {
	"yellow": Color(1.0, 0.812, 0.039, 1.0),
	"blue": Color(0.0, 0.323, 0.983, 1.0),
	"red": Color(1.0, 0.161, 0.118, 1.0),
	"light_blue": Color(0.0, 0.627, 0.878, 1.0),
	"green": Color(0.0, 0.549, 0.141, 1.0),
	"pink": Color(1.0, 0.533, 0.639, 1.0),
	"orange": Color(0.886, 0.396, 0.224, 1.0),
	"bolot": Color(0.612, 0.604, 0.216, 1.0),
	"full_pink": Color(0.839, 0.302, 0.608, 1.0),
	"light_yellow": Color(1.0, 0.812, 0.039, 1.0),
	"turquoise": Color(0.208, 0.769, 0.576, 1.0),
	"light_orange": Color(1.0, 0.565, 0.282, 1.0),
	"lavanda": Color(1.0, 0.624, 0.706, 1.0),
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
