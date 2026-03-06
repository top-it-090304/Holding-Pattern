extends Node

var start_planes: int = 5

var lines_data = {
	"current color" = "yellow",
	"current hex color" = Color(1, 1, 0, 0.7),
	"active colors" = ["yellow", "blue", "red"],

	"in_yellow" = false,
	"yellow_routes" = [],  # теперь храним словари с данными о маршрутах
	"yellow_airports" = [],
	"yellow_planes" = [],
	
	"in_blue" = false,
	"blue_routes" = [],
	"blue_airports" = [],
	"blue_planes" = [],
	
	"in_red" = false,
	"red_routes" = [],
	"red_airports" = [],
	"red_planes" = [],
}
