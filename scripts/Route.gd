extends Node2D

# Используем load, чтобы избежать ошибки instantiate на null
var plane_scene = load("res://scene/Plane.tscn")
@onready var buttons_script = $"/root/Main"

func _ready():
	buttons_script.color_changed.connect(create_line)

func create_line(airport_a, airport_b, new_color):
	
	var line = Line2D.new()
	add_child(line)
	line.width = 4.0
	line.default_color = new_color
	line.z_index = -1
 
	var curve = Curve2D.new()
	var p0 = airport_a.position
	var p2 = airport_b.position
 
	var mid = (p0 + p2) / 2
	# PI/2 — это 90 градусов в радианах
	var offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	var p1_a = mid + offset
 
	var control_relative = p1_a - p0
 
	curve.add_point(p0, Vector2.ZERO, control_relative)
	curve.add_point(p2)
 
	line.points = curve.get_baked_points()
 
	if plane_scene:
		var plane = plane_scene.instantiate()
		add_child(plane)
		plane.setup_with_curve(curve)
