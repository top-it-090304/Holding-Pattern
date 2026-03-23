extends Sprite2D

var path_points: PackedVector2Array
var speed: float
var total_length: float = 0.0
var duration: float

var progress: float = 0.0
var flying_forward: bool = true

func start_flight(points: PackedVector2Array, flight_speed: float):
	path_points = points
	speed = flight_speed
	
	for i in range(path_points.size() - 1):
		total_length += path_points[i].distance_to(path_points[i+1])
		
	duration = total_length / speed
	global_position = path_points[0]

func _process(delta):
	
	if path_points.size() < 2: return
	
	if flying_forward:
		progress += delta / duration
		if progress >= 1.0:
			progress = 1.0
			await get_tree().create_timer(1.4).timeout
			flying_forward = false
	else:
		progress -= delta / duration
		if progress <= 0.0:
			progress = 0.0
			await get_tree().create_timer(1.4).timeout
			flying_forward = true
			
	var target_distance = progress * total_length
	var current_dist = 0.0
	
	
	for i in range(path_points.size() - 1):
		var p1 = path_points[i]
		var p2 = path_points[i+1]
		var seg_len = p1.distance_to(p2)
		
		if current_dist + seg_len >= target_distance or i == path_points.size() - 2:
			var t = 0.0
			if seg_len > 0:
				t = (target_distance - current_dist) / seg_len
				
			var new_pos = p1.lerp(p2, t)
			
			var direction = new_pos - global_position
			if direction.length() > 0.01:
				rotation = direction.angle()
				
			global_position = new_pos
			break
			
		current_dist += seg_len
