extends TextureRect

var is_dragging = false
var ghost_plane: Sprite2D
@onready var fly_count = %TexturePlaneGhost

func _process(_delta):
	if GameData.start_planes == 0:
		texture = load("res://objects/count_fly_Zero.png")
	if is_dragging and is_instance_valid(ghost_plane):
		ghost_plane.global_position = get_viewport().get_mouse_position()


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and GameData.start_planes > 0:
			is_dragging = true
			_create_ghost()
		elif not event.pressed and is_dragging:
			_drop_plane()

func _create_ghost():
	ghost_plane = Sprite2D.new()
	ghost_plane.texture = fly_count.texture
	ghost_plane.modulate = Color(1, 1, 1, 0.5)
	get_parent().add_child(ghost_plane)
	ghost_plane.top_level = true
	ghost_plane.z_index = 11
	ghost_plane.scale = Vector2(1.0,1.0)
	ghost_plane.global_position = get_viewport().get_mouse_position()
	


func _drop_plane():
	is_dragging = false
	var canvas_transform = get_viewport().get_canvas_transform()
	var mouse_pos = canvas_transform.affine_inverse() * get_viewport().get_mouse_position()
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
		found_route.spawn_plane(route_data_, t_)
		print("самолет появился")
		
	
	
