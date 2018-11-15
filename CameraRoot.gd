extends Spatial

var _rotations = [
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*0) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*1) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*2) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*3) % 360 )))
				]

var _rotation_speed = 0.5
var _progress = _rotation_speed

var _rotation_index = 0
#var _next_rotation_index = 0

func _ready():
	set_process_input(true)
	set_process(true)
	set_transform(_rotations[_rotation_index])

func _process(delta):
	_progress += delta
	if _progress < _rotation_speed:
		var t = get_transform()
		var s = Quat(_rotations[_rotation_index].basis)
		var slerpd = Quat(t.basis).slerp(s, clamp(_progress / _rotation_speed, 0, 1.0))
		set_transform(Transform(slerpd))
	else:
		set_transform(Transform(Quat(_rotations[_rotation_index].basis)))

func _input(event):
	if event.is_action_pressed("rotate_left") && _progress > _rotation_speed:
		_progress = 0.0
		_rotate_left()
	elif event.is_action_pressed("rotate_right") && _progress > _rotation_speed:
		_progress = 0.0
		_rotate_right()

func _rotate_left():
	_rotation_index += -1
	_rotation_index %= _rotations.size()

func _rotate_right():
	_rotation_index += 1
	_rotation_index %= _rotations.size()