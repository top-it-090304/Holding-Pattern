extends Sprite2D

var path_points: PackedVector2Array
var target_speed: float
var current_speed: float = 0.0
var total_length: float = 0.0

var t: float = 0.0
var forward: bool = true
var is_waiting: bool = false

func start_flight(points: PackedVector2Array, flight_speed: float):
	path_points = points
	target_speed = flight_speed
	
	for i in range(path_points.size() - 1):
		total_length += path_points[i].distance_to(path_points[i+1])
		
	global_position = path_points[0]
	_start()

func _process(delta):
	if path_points.size() < 2 or is_waiting: return
	var stop_margin = 0.15
	var dist_to_target = (1.0 - t) if forward else t
	
	if dist_to_target < stop_margin:
		var slow_factor = clamp(dist_to_target / stop_margin, 0.1, 1.0)
		current_speed = lerp(current_speed, target_speed * slow_factor, 5.0 * delta)
	else:
		current_speed = lerp(current_speed, target_speed, 2.0 * delta)
		
	var step = (current_speed * delta) / total_length
	if forward:
		t += step
		if t >= 1.0:
			t = 1.0
			_stop()
	else:
		t -= step
		if t <= 0.0:
			t = 0.0
			_stop()
			
	_update_position_and_rotation()

func _update_position_and_rotation():
	var target_distance = t * total_length
	var current_dist = 0.0
	
	for i in range(path_points.size() - 1):
		var p1 = path_points[i]
		var p2 = path_points[i+1]
		var seg_len = p1.distance_to(p2)
		
		if current_dist + seg_len >= target_distance or i == path_points.size() - 2:
			var t_ = 0.0
			if seg_len > 0:
				t_ = (target_distance - current_dist) / seg_len
				
			var new_pos = p1.lerp(p2, t_)
			
			var direction = new_pos - global_position
			if direction.length() > 0.1:
				var target_angle = direction.angle()
				rotation = lerp_angle(rotation, target_angle, 8.0 * get_process_delta_time())
				
			global_position = new_pos
			break
		current_dist += seg_len

func _stop():
	is_waiting = true
	current_speed = 0.0
	await get_tree().create_timer(1.6).timeout
	forward = !forward
	is_waiting = false
	_start()

func _start():
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "current_speed", target_speed, 1.5)
