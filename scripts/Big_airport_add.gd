extends TextureRect

var is_dragging = false
var ghost_plane: Sprite2D
@onready var fly_ghost = %TextureRect

func _ready():
	$".".visible = false
	Events.stop_plane_add.connect(_stop_plane_add)

func _process(_delta):
	if GameData.big_airports == 0:
		texture = load("res://objects/count_airport_Zero.png")
	if GameData.big_airports > 0:
		$".".visible = true
		texture = load("res://objects/Bonus_airport.png")
	if is_dragging and is_instance_valid(ghost_plane):
		var mouse_pos_viewport = get_viewport().get_mouse_position() + Vector2(0, -180)
		ghost_plane.global_position = mouse_pos_viewport
		for airport in get_tree().get_nodes_in_group("airports"):
			var dist = (get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position() + Vector2(0.0, -90.0)).distance_to(airport.position)
			if dist < 60:
				var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(airport, "scale", Vector2(1.2, 1.2), 0.25)
			else:
				var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(airport, "scale", Vector2(1, 1), 0.25)

func _get_closest_route_data(world_pos):
	var min_dist = 60.0
	var closest_data = null
	
	for route in get_tree().get_nodes_in_group("routes"):
		for curve in route.my_curves:
			var offset = curve.get_closest_offset(world_pos)
			var point = curve.sample_baked(offset)
			var d = world_pos.distance_to(point)
			
			if d < min_dist:
				min_dist = d
				closest_data = {
					"curve": curve,
					"color": GameData.color_values[route.route_data.color]
				}
	return closest_data
	
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and GameData.big_airports > 0:
			is_dragging = true
			_create_ghost()
		elif not event.pressed and is_dragging:
			is_dragging = false
			_drop_plane()

func _create_ghost():
	SoundManager.play("tap_add_plane")
	ghost_plane = Sprite2D.new()
	ghost_plane.texture = fly_ghost.texture
	ghost_plane.modulate = Color(1, 1, 1, 0.5)
	get_parent().add_child(ghost_plane)
	ghost_plane.top_level = true
	ghost_plane.z_index = 11
	ghost_plane.scale = Vector2(2.2, 2.2)
	ghost_plane.global_position = get_viewport().get_mouse_position()  + Vector2(0.0, -180.0)
	
func _stop_plane_add():
	if is_instance_valid(ghost_plane):
		ghost_plane.queue_free()
	is_dragging = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	

func _drop_plane():
	is_dragging = false
	var canvas_transform = get_viewport().get_canvas_transform()
	var mouse_pos = canvas_transform.affine_inverse() * get_viewport().get_mouse_position() + Vector2(0.0, -90.0)
	var min_dist = 60.0
	
	for airport in get_tree().get_nodes_in_group("airports"):
		
		var dist = mouse_pos.distance_to(airport.position)
		
		if dist < min_dist:
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(airport, "scale", Vector2(1.35, 1.35), 0.25)
			GameData.big_airports -= 1
			airport.is_big = true
			airport.max_passengers = GameData.big_max_passengers
			var CountAirport = get_tree().get_first_node_in_group("countBigAirport")
			if CountAirport:
				CountAirport.on_plane_spawned()
			break
	
	if ghost_plane:
		ghost_plane.queue_free()
		SoundManager.play("add_plane")
