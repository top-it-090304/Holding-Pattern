extends TextureRect

var is_dragging = false
var ghost_plane: Sprite2D
@onready var fly_ghost = %TexturePlaneGhost

func _ready():
		Events.stop_plane_add.connect(_stop_plane_add)
		
func _process(_delta):
	if GameData.start_planes == 0:
		texture = load("res://objects/count_fly_Zero.png")
	if GameData.start_planes > 0:
		texture = load("res://objects/Bonus_Plane.png")
	if is_dragging and is_instance_valid(ghost_plane):
		var mouse_pos_viewport = get_viewport().get_mouse_position() + Vector2(0, -180)
		ghost_plane.global_position = mouse_pos_viewport
		var canvas_transform = get_viewport().get_canvas_transform()
		var mouse_pos_world = canvas_transform.affine_inverse() * mouse_pos_viewport
		
		var found_data = _get_closest_route_data(mouse_pos_world)
		
		if found_data:
			## цвет по линии
			ghost_plane.modulate = ghost_plane.modulate.lerp(found_data.color, 0.15)
			ghost_plane.modulate.a = 0.7
			## поворот по линии
			var curve = found_data.curve
			var offset = curve.get_closest_offset(mouse_pos_world)
			
			var pos1 = curve.sample_baked(offset)
			var pos2 = curve.sample_baked(offset + 2.0)
			
			var direction = pos2 - pos1
			if direction.length() > 0.1:
				var target_angle = direction.angle() 
				ghost_plane.rotation = lerp_angle(ghost_plane.rotation, target_angle, 10.0 * _delta)
		else:
			ghost_plane.modulate = Color(1, 1, 1, 0.5)
			ghost_plane.rotation = lerp_angle(ghost_plane.rotation, 0, 10.0 * _delta)
			
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
		if event.pressed and GameData.start_planes > 0:
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
	ghost_plane.scale = Vector2(2.0, 2.0)
	ghost_plane.global_position = get_viewport().get_mouse_position()  + Vector2(0.0, -180.0)
	
func _stop_plane_add():
	if is_instance_valid(ghost_plane):
		ghost_plane.queue_free()
	is_dragging = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	

func _drop_plane():
	is_dragging = false
	var canvas_transform = get_viewport().get_canvas_transform()
	var mouse_pos = canvas_transform.affine_inverse() * get_viewport().get_mouse_position() + Vector2(0.0, -100.0)
	var found_route = null
	var route_data_ = null
	var t_ = 0.0
	var min_dist = 60.0

	for route in get_tree().get_nodes_in_group("routes"):
		for curve in route.my_curves:
			var offset = curve.get_closest_offset(mouse_pos)
			var point_on_curve = curve.sample_baked(offset)
			var dist = mouse_pos.distance_to(point_on_curve)
			
			if dist < min_dist:
				min_dist = dist
				found_route = route
				route_data_ = route.route_data
				t_ = offset / curve.get_baked_length()
				
	if ghost_plane:
		ghost_plane.queue_free()
				


	if found_route and route_data_:
		found_route.spawn_plane(route_data_, t_, false)
		SoundManager.play("add_plane")
		print("самолет появился")
		
	
	
