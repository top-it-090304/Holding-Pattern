extends Sprite2D

var flight_rout: Curve2D
var t: float = 0.0
var speed: float = 180.0
var forward: bool = true
var total_lenght: float = 0.0


func setup_with_curve(curve: Curve2D):
	flight_rout = curve
	total_lenght = curve.get_baked_length()
	position = curve.get_point_position(0)
 
func _process(delta):
	if forward:
		t += speed * delta
		if t >= total_lenght:
			forward = false
	else:
		t -= speed * delta
		if t <= 0:
			forward = true
 
	var new_pos = flight_rout.sample_baked(t)
	look_at(new_pos + (new_pos - position))
	position = new_pos
