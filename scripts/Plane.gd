extends Sprite2D

var start_pos: Vector2
var end_pos: Vector2
var speed: int = 200
var t: float = 0.0
var forward: bool = true

func setup(a: Vector2, b: Vector2):
	start_pos = a
	end_pos = b
	

func _process(delta):
	var distance = start_pos.distance_to(end_pos)
	var step = (speed * delta) / distance
 
	if forward:
		t += step
		if t >= 1.0:
			t = 1.0
			forward = false
	else:
		t -= step
		if t <= 0.0:
			t = 0.0
			forward = true
   
	position = start_pos.lerp(end_pos, t)
 
 ## поворот самолета (ХУЙ)*
	var look_target = end_pos if forward else start_pos
	look_at(look_target)
