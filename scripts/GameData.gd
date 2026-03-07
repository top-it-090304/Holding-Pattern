extends Node

var start_planes: int = 3

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
}

var color_values = {
	"yellow": Color(1.0, 0.812, 0.039, 1.0),
	"blue": Color(0.0, 0.323, 0.983, 1.0),
	"red": Color(1.0, 0.161, 0.118, 1.0)
}
