extends Sprite2D

var flight_path: Curve2D
var t: float = 0.0         
var speed: float = 0.4     
var forward: bool = true

func setup_with_curve(curve: Curve2D, start_offset: float = 0.0):
	flight_path = curve
	t = start_offset 
	position = curve.sample_baked(t * curve.get_baked_length())

func _process(delta):
	if not flight_path: return
 
	if forward:
		t += speed * delta
		if t >= 1.0: t = 1.0; arrival()
	else:
		t -= speed * delta
		if t <= 0.0: t = 0.0; arrival()

	var dist = t * flight_path.get_baked_length()
	position = flight_path.sample_baked(dist)
	look_at(flight_path.sample_baked(dist + (0.1 if forward else -0.1)))

func arrival():
	forward = !forward
	set_process(false)
	await get_tree().create_timer(0.8).timeout
	set_process(true)
