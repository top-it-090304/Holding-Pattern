extends TextureRect

var is_dragging = false
var ghost_plane: Sprite2D

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and GameData.start_planes > 0:
			is_dragging = true
			_create_ghost()
		elif not event.pressed and is_dragging:
			_drop_plane()

func _create_ghost():
	ghost_plane = Sprite2D.new()
	ghost_plane.texture = texture
	ghost_plane.modulate = Color(1, 1, 1, 0.5)
	ghost_plane.scale = Vector2(0.5, 0.5)
	ghost_plane.top_level = true
	add_child(ghost_plane)

func _process(_delta):
	if is_dragging and ghost_plane:
		ghost_plane.global_position = get_global_mouse_position()

func _drop_plane():
	is_dragging = false
	var mouse_pos = get_global_mouse_position()
	var routes = get_tree().get_nodes_in_group("routes")
	var success = false
	
	for route in routes:
		if not route.my_curves.is_empty():
			var first_point = route.my_curves[0].get_point_position(0)
			if mouse_pos.distance_to(first_point) < 50:
				if route.add_plane_button():
					success = true
					print("-1 самолет", GameData.start_planes)
					break
	
	if not success:
		print("самолеты кончится")
		
	ghost_plane.queue_free()
