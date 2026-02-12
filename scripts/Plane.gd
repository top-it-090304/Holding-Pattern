extends Sprite2D

var flight_path: Curve2D
var t: float = 0.0         
var speed: float = 0.4     
var forward: bool = true

func setup_with_curve(curve: Curve2D):
 flight_path = curve
 position = curve.get_point_position(0)

func _process(delta):
 if not flight_path: return



 var slow_speed = speed * (0.2 + 0.5 * sin(t * PI))
 
 if forward:
  t += slow_speed * delta
  if t >= 1.0:
   t = 1.0
   arrival()
 else:
  t -= slow_speed * delta
  if t <= 0.0:
   t = 0.0
   arrival()


 var dist = t * flight_path.get_baked_length()
 var new_pos = flight_path.sample_baked(dist)
 
 look_at(new_pos)
 position = new_pos

func arrival():
 forward = !forward
 set_process(false)
 await get_tree().create_timer(0.8).timeout
 set_process(true)
