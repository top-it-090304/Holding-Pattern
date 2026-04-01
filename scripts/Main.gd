extends Node2D

var airport_scene = load("res://scene/Airport.tscn")
var route_scene = load("res://scene/Route.tscn")


@onready var spawn_points := $AirportSpawn
@onready var camera := $Camera2D
@onready var score_pack = $UI/ScorePack
@onready var score_label = $UI/ScorePack/Score
@onready var game_over_ui = $GameOverUI
@onready var vinetka =  $GameOverUI/MainPack/Vinetka
@onready var score_final_label = $GameOverUI/MainPack/ScoreLabel
@onready var text_game_over = $GameOverUI/MainPack/Text
@onready var main_pack = $GameOverUI/MainPack

@onready var buttons = [$GameOverUI/MainPack/Restart, $GameOverUI/MainPack/Menu]

@onready var inactive_buttons = [$UI/LightBlueButton, $UI/GreenButton, $UI/PinkButton, $UI/OrangeButton]
var active_button: Node = null


var hover_scale = Vector2(1.2, 1.2)
var normal_scale = Vector2(1.0, 1.0)
var faded_alpha = Color(1, 1, 1, 0.3)
var normal_alpha = Color(1, 1, 1, 1.0)
var scale_hovered = Vector2(1.15, 1.15)
var scale_others = Vector2(0.85, 0.85)
var scale_normal = Vector2(1.0, 1.0)
var alpha_faded = Color(1, 1, 1, 0.4)
var alpha_full = Color(1, 1, 1, 1.0)
var duration = 0.12

var passengers_delivery: int = 0
var passenger_timer: Timer
var skip_spawn: int = 0
var storage_stack: bool = false
var stack_chanse: float = 0.20

var start_shapes = [
	GameData.ShapeType.CIRCLE,
	GameData.ShapeType.SQUARE,
	GameData.ShapeType.TRIANGLE
]



var all_zones: Array = []
var active_airport: Array[Vector2] = []
var airport_points: Array[Vector2] = []

var current_phase: int = 0
var max_phases: int = 0

var target_zoom := Vector2(2.4, 2.4)

var selected_airport = null
var is_drawing: bool = false
var pred_line: Line2D

var lines_data = GameData.lines_data
var clear_data_twin: Tween

func _ready():
	$GameOverUI.visible = false
	
	score_pack.modulate.a = 0
	score_pack.visible = false
	score_pack.scale = Vector2(0.5, 0.5)
	pred_line = Line2D.new()
	pred_line.width = 9.0
	pred_line.z_index = -1
	add_child(pred_line)
 
	for zone_node in spawn_points.get_children():
		var zone_points: Array[Vector2] = []
		for marker in zone_node.get_children():
			if marker is Marker2D:
				zone_points.append(marker.global_position)
		zone_points.shuffle()
		all_zones.append(zone_points)
		
	max_phases = all_zones.size()
	unlock_next_phase()
	
	Events.passengers_delivery.connect(_on_passengers_delivery)
	animate_score()
		
	passenger_timer = Timer.new()
	passenger_timer.wait_time = 3.0
	passenger_timer.autostart = true
	passenger_timer.timeout.connect(_on_passenger_timer_timeout)
	add_child(passenger_timer)
	
	var phase_timer = Timer.new()
	phase_timer.wait_time = 100.0 ## таймер на новую зону
	phase_timer.autostart = true
	phase_timer.timeout.connect(_on_phase_timer_timeout)
	add_child(phase_timer)
	
	for i in range(3):
		spawn_airport()
		
	score_pack.scale = Vector2.ZERO
	score_pack.modulate.a = 0
	get_tree().create_timer(1.0).timeout.connect(animate_score)
	
	for btn in buttons:
		if is_instance_valid(btn):
			btn.pivot_offset = btn.size / 2
			btn.mouse_entered.connect(_on_button_hovered.bind(btn))
			btn.mouse_exited.connect(_on_button_unhovered)
	
func _process(delta):
	if is_drawing and selected_airport and is_instance_valid(pred_line):
		var current_color = GameData.lines_data["current hex color"]
		pred_line.default_color = Color(current_color.r, current_color.g, current_color.b)
		
		line_draw(selected_airport.global_position, get_global_mouse_position())
		check_airport()
	if camera:
		var zoom_speed = 0.06 ## скорость камеры
		camera.zoom = camera.zoom.lerp(target_zoom, zoom_speed * delta)
		
func _stop_line_create():
	for airport in get_tree().get_nodes_in_group("airports"):
		airport.draw_stroke(false)
	selected_airport = null
	is_drawing = false
	if is_instance_valid(pred_line):
		pred_line.clear_points()
	
func animate_score():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(score_pack, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(score_pack, "modulate:a", 1.0, 0.4)

func _on_passengers_delivery():
	passengers_delivery += 1
	score_label.text = str(passengers_delivery)
	if passengers_delivery == 1:
		_show_score()
		
func _show_score():
	score_pack.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(score_pack, "modulate:a", 1.0, 0.5)
	tween.tween_property(score_pack, "scale", Vector2(1.0,1.0), 0.2).from(Vector2(0.8, 0.8))
	
	
func _on_phase_timer_timeout():
	unlock_next_phase()
	

func unlock_next_phase():
	if current_phase < max_phases:
		active_airport.append_array(all_zones[current_phase])
		active_airport.shuffle()
		
		var zoom_value = max(2.4 - (current_phase * 0.3), 0.9)
		
		target_zoom = Vector2(zoom_value, zoom_value)
		
		current_phase += 1
		if passenger_timer:
			var new_speed = max(1.0, 0.3 - (current_phase * 0.5))
			passenger_timer.wait_time = new_speed
			print(new_speed)
			passenger_timer.start()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_drawing = true
				set_line_stroke(true)
			else:
				set_line_stroke(false)
				is_drawing = false
				stop_draw()

func line_draw(pos1: Vector2, pos2: Vector2):
	if not is_instance_valid(pred_line):
		return
	var curve = Curve2D.new()
	var p0 = pos1
	var p2 = pos2
	
	if p2.x > p0.x:
		var C = p0
		p0 = p2
		p2 = C
		
	var mid = (p0 + p2) / 2
	var offset = (p2 - p0).rotated(PI/2).normalized() * (p0.distance_to(p2) * 0.2)
	var control_point = (mid + offset) - p0
 
	curve.add_point(p0, Vector2.ZERO, control_point)
	curve.add_point(p2)
	pred_line.points = curve.get_baked_points()

func check_airport():
	var mouse_pos = get_global_mouse_position()
	var permission = false
	
	for airport in get_tree().get_nodes_in_group("airports"):
		
		if airport != selected_airport and airport.global_position.distance_to(mouse_pos) < 50 and ((len(lines_data[lines_data["current color"] + "_airports"]) >= 3 and airport == lines_data[lines_data["current color"] + "_airports"][0]) or (airport not in lines_data[lines_data["current color"] + "_airports"])):
			permission = true
		
		for route in get_tree().get_nodes_in_group("routes"):
			if selected_airport == route.route_data["start_airport"] and airport == route.route_data["end_airport"] or selected_airport == route.route_data["end_airport"] and airport == route.route_data["start_airport"]:
				permission = false
		
		if permission:
			permission = false
			airport.activate_pulse() 
			
			if not lines_data["in_" + lines_data["current color"]]:
				lines_data[lines_data["current color"] + "_airports"].append(selected_airport)
			lines_data[lines_data["current color"] + "_airports"].append(airport)
			
			create_route(selected_airport, airport)
			if airport == lines_data[lines_data["current color"] + "_airports"][0]:
				stop_draw()
				break
			selected_airport = airport
			selected_airport.draw_stroke(true)

func create_route(a, b):
	var route = route_scene.instantiate()
	route.add_to_group("routes")
	add_child(route)
	route.create_line(a, b)

func stop_draw():
	for airport in get_tree().get_nodes_in_group("airports"):
		airport.draw_stroke(false)
	selected_airport = null
	is_drawing = false
	pred_line.clear_points()

func spawn_airport():
	if active_airport.is_empty(): return
	var inst = airport_scene.instantiate()
	inst.position = active_airport.pop_back()
	
	if not start_shapes.is_empty():
		inst.forced_shape = start_shapes.pop_front()
		
	inst.add_to_group("airports")
	inst.airport_selected.connect(_on_airport_selected)
	inst.end_game.connect(game_over)
	add_child(inst)
	
func set_line_stroke(is_active: bool):
	if is_active and not is_drawing: 
		return
	var current_color = GameData.lines_data["current color"]
	var hex_color = GameData.lines_data["current hex color"]
	
	var airports = []
	if not GameData.lines_data.has(current_color + "_routes"): return
	
	for route in GameData.lines_data[current_color + "_routes"]:
		if not route.start_airport in airports: airports.append(route.start_airport)
		if not route.end_airport in airports: airports.append(route.end_airport)
	
	for a in airports:
		if is_instance_valid(a):
			a.toggle_stroke(is_active, hex_color)


func _on_airport_selected(airport):
	var current_color = lines_data["current color"]
	if lines_data["in_" + lines_data["current color"]] and airport == lines_data[lines_data["current color"] + "_airports"][0]:
		var a = lines_data[lines_data["current color"] + "_airports"][0]
		lines_data[lines_data["current color"] + "_airports"][0] = lines_data[lines_data["current color"] + "_airports"][-1]
		lines_data[lines_data["current color"] + "_airports"][-1] = a
	
	selected_airport = airport
	is_drawing = true
	selected_airport.draw_stroke(true)
	
	for a in lines_data[current_color + "_airports"]:
		if is_instance_valid(a):
			a.draw_stroke(true)
	
func _on_passenger_timer_timeout():
	if not storage_stack and randf() < stack_chanse:
		storage_stack = true
		skip_spawn = 1
		return
		
	if storage_stack:
		skip_spawn += 1
		if skip_spawn >= 3:
			storage_stack = false
			skip_spawn = 0
			
			if randf() > 0.5:
				_spawn_burst_two_passenger(2)
			else:
				_spawn_stack_passenger(randi_range(3,4))
		return 
		
	_spawn_one_passenger()
	
func _spawn_burst_two_passenger(amount: int):
	var target_airport = _get_airport_()
	if not target_airport: return
	
	for i in range(amount):
		if target_airport.passenger_manager.passengers.size() < 9:
			target_airport.spawn_passenger()
			await get_tree().create_timer(0.2).timeout
			
func _spawn_stack_passenger(amount: int):
	for i in range(amount):
		var target_airport = _get_airport_()
		if target_airport:
			target_airport.spawn_passenger()
			
			await get_tree().create_timer(0.1).timeout
			
func _get_airport_():
	var airports = get_tree().get_nodes_in_group("airports")
	airports.shuffle()
	for a in airports:
		if a.passenger_manager.passengers.size() < 9:
			return a
	return null

func _spawn_one_passenger():
	var target = _get_airport_()
	if target:
		target.spawn_passenger()
	
func game_over(_failed_airport):
	print("stop")
	get_tree().paused = true
	$UI.visible = false
	
	camera.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_ui.show()
	main_pack.self_modulate.a = 0.0
	
	
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(camera, "global_position", _failed_airport.global_position, 2.5)
	
	var crash_zoom = Vector2(3.5, 3.5)
	tween.tween_property(camera, "zoom", crash_zoom, 2.5)
	tween.tween_property(camera, "rotation", 0.45, 1.5)
	
	tween.tween_interval(2.0)
	
	tween.tween_callback(func():score_final_label.text = str(passengers_delivery))
	tween.tween_property(main_pack, "self_modulate:a", 1.0, 1.8).from(0.0)
	
	var current_score = int(score_label.text)
	GameData.save_highscore(current_score)
	
	score_final_label.text = "Score: " + str(current_score)


func _setup_vignette(_airport):
	vinetka.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	vinetka.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
## кнопки
func _on_yb_pressed():
	set_line_stroke(false)
	_animate_clear_button($UI/YellowButton)
	lines_data["current color"] = "yellow"
	lines_data["current hex color"] = Color(1.0, 0.812, 0.039, 1.0)

func _on_bb_toggled():
	set_line_stroke(false)
	_animate_clear_button($UI/BlueButton)
	lines_data["current color"] = "blue"
	lines_data["current hex color"] = Color(0.0, 0.323, 0.983, 1.0)

func _on_rb_toggled():
	set_line_stroke(false)
	_animate_clear_button($UI/RedButton)
	lines_data["current color"] = "red"
	lines_data["current hex color"] = Color(1.0, 0.0, 0.0, 1.0)

func _on_lbb_toggled() -> void:
	set_line_stroke(false)
	_animate_clear_button($UI/LightBlueButton)
	lines_data["current color"] = "light_blue"
	lines_data["current hex color"] = Color(0.0, 0.627, 0.878, 1.0)

func _on_gb_toggled() -> void:
	set_line_stroke(false)
	_animate_clear_button($UI/GreenButton)
	lines_data["current color"] = "green"
	lines_data["current hex color"] = Color(0.0, 0.549, 0.141, 1.0)

func _on_pb_toggled() -> void:
	set_line_stroke(false)
	_animate_clear_button($UI/PinkButton)
	lines_data["current color"] = "pink"
	lines_data["current hex color"] = Color(1.0, 0.533, 0.639, 1.0)

func _on_ob_toggled() -> void:
	set_line_stroke(false)
	_animate_clear_button($UI/OrangeButton)
	lines_data["current color"] = "orange"
	lines_data["current hex color"] = Color(0.886, 0.396, 0.224, 1.0)

func _on_restart_pressed():
	get_tree().paused = false
	for color in GameData.lines_data["active colors"]:
		clear_data(color)
	GameData.lines_data["active colors"] = ["yellow", "blue", "red"]
	GameData.lines_data["inactive colors"] = ["light_blue", "green", "pink", "orange"]
	get_tree().change_scene_to_file("res://scene/Main.tscn")
	GameData.start_planes = 3

func _on_menu_pressed():
	get_tree().paused = false
	for color in GameData.lines_data["active colors"]:
		clear_data(color)
	GameData.lines_data["active colors"] = ["yellow", "blue", "red"]
	GameData.lines_data["inactive colors"] = ["light_blue", "green", "pink", "orange"]
	get_tree().change_scene_to_file("res://scene/StartMenu.tscn")
	GameData.start_planes = 3

func _on_button_hovered(hovered_btn):
	for btn in buttons:
		if not is_instance_valid(btn): continue
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		
		if btn == hovered_btn:
			tween.tween_property(btn, "scale", scale_hovered, duration)
			tween.tween_property(btn, "modulate", alpha_full, duration)
		else:
			tween.tween_property(btn, "scale", scale_others, duration)
			tween.tween_property(btn, "modulate", alpha_faded, duration)
			
func _on_button_unhovered():
	for btn in buttons:
		if not is_instance_valid(btn): continue
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(btn, "scale", scale_normal, duration)
		tween.tween_property(btn, "modulate", alpha_full, duration)

func _on_spawn_timer_timeout():
	spawn_airport()

func clear_data(current_color):
	GameData.start_planes += len(GameData.lines_data[current_color + "_planes"])
	if GameData.lines_data[current_color + "_planes"]:
		for plane in GameData.lines_data[current_color + "_planes"]:
			plane.queue_free()
	get_tree().get_nodes_in_group("countPlane")[0].update_counter()
	for route in GameData.lines_data[current_color + "_routes"]:
		route["route"].queue_free()
	GameData.lines_data["in_" + current_color] = false
	GameData.lines_data[current_color + "_routes"].clear()
	GameData.lines_data[current_color + "_airports"].clear()
	GameData.lines_data[current_color + "_planes"].clear()
	GameData.lines_data[current_color + "_shapes"].clear()
	

func _animate_clear_button(target_btn: Node):
	if active_button == target_btn:
		_close_clear_animation(target_btn)
		active_button = null
		return
		
	if active_button != null:
		_close_clear_animation(active_button)
		
	active_button = target_btn
	_open_clear_animation(target_btn)

func _open_clear_animation(target_btn: Node):
	var clear_btn = $UI/ClearData
	if is_instance_valid(clear_data_twin):
		clear_data_twin.kill()
	
	var out_pos = target_btn.global_position + Vector2(-76, -15)
	var in_pos = target_btn.global_position + Vector2(10, 10)
	
	clear_data_twin = create_tween().set_parallel(true)
	clear_data_twin.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if clear_btn.modulate.a < 0.1 or not clear_btn.visible:
		clear_btn.visible = true
		clear_btn.global_position = in_pos
		clear_btn.modulate.a = 0.0
		clear_data_twin.tween_property(clear_btn, "modulate:a", 1.0, 0.1)
		
	clear_data_twin.tween_property(clear_btn, "global_position", out_pos, 0.25)
	
func _close_clear_animation(target_btn: Node):
	var clear_btn = $UI/ClearData
	if is_instance_valid(clear_data_twin):
		clear_data_twin.kill()
		
	var in_pos = target_btn.global_position + Vector2(10, 10)
	
	clear_data_twin = create_tween().set_parallel(true)
	clear_data_twin.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	clear_data_twin.tween_property(clear_btn, "global_position", in_pos, 0.2)
	clear_data_twin.tween_property(clear_btn, "modulate:a", 0.0, 0.1)
	clear_data_twin.chain().tween_callback(func(): clear_btn.visible = false)

func _on_clear_data_pressed() -> void:
	clear_data(GameData.lines_data["current color"])

func _on_week_timer_timeout() -> void:
	Events.stop_plane_add.emit()
	_stop_line_create()
	get_tree().paused = true
	$UI/BonusPlane.show()
	GameData.current_week += 1
	$UI/BonusPlane/Label.text = "Неделя " + str(GameData.current_week)
	$UI/BonusLine/Label.text = "Неделя " + str(GameData.current_week)
	$UI/BonusBigPlane/Label.text = "Неделя " + str(GameData.current_week)

func _on_bonus_plane_pressed() -> void:
	get_tree().get_nodes_in_group("countPlane")[0].add_bonus_planes(1)
	$UI/BonusPlane.hide()
	if GameData.lines_data["inactive colors"]:
		$UI/BonusLine.show()
	else: 
		get_tree().paused = false

func _on_bonus_line_pressed() -> void:
	var path = "res://objects/Button_" + GameData.lines_data["inactive colors"][0] + ".png"
	inactive_buttons[0].icon = load(path)
	GameData.lines_data["active colors"].append(GameData.lines_data["inactive colors"].pop_at(0))
	inactive_buttons.pop_at(0).disabled = false
	$UI/BonusLine.hide()
	$UI/BonusBigPlane.show()


func _on_bonus_big_plane_pressed() -> void:
	get_tree().get_nodes_in_group("countBigPlane")[0].add_bonus_planes(1)
	
	$UI/BonusBigPlane.hide()
	get_tree().paused = false
