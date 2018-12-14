extends Spatial

signal rotation_start
signal rotation_end

var _rotating = false
func rotating():
	return _rotating

var _filter_color = Color(1,1,1) setget set_filter_color,get_filter_color

func set_filter_color(color):
	_filter_color = color
	$Camera.Filter.get_surface_material(0).set("albedo_color", _filter_color)
func get_filter_color():
	return _filter_color

var _rotations = [
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*0) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*1) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*2) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*3) % 360 )))
				]

var _rotation_speed = 0.75
var _progress = _rotation_speed

var _rotation_index = 0
func get_rotation_index():
	return _rotation_index
#func get_rotation_from_index(index = 0):
#	index = index % 4
#	return _rotations[index]

func _ready():
	set_process_input(true)
	set_process(true)
	set_transform(_rotations[_rotation_index])
	$Camera2.queue_free()
	$Camera3.queue_free()
	$Camera4.queue_free()

func _process(delta):
	_progress += delta
	if _progress < _rotation_speed:
		var t = get_transform()
		var s = Quat(_rotations[_rotation_index].basis)
		var ratio = clamp(_progress / _rotation_speed, 0, 1.0)
		var slerpd = Quat(t.basis).slerp(s, ratio)
		Music.pitch_scale = min(1.0, ratio * 4.0 + 0.33)
		set_transform(Transform(slerpd))
	else:
		if _rotating == true:
			_rotating = false
			emit_signal("rotation_end")
		set_transform(Transform(Quat(_rotations[_rotation_index].basis)))
		Music.pitch_scale = 1
	set_translation(get_node("../GZEMO").get_translation())

func _input(event):
	if event.is_action_pressed("rotate_left") && _progress > _rotation_speed:
		_progress = 0.0
		_rotate_left()
	elif event.is_action_pressed("rotate_right") && _progress > _rotation_speed:
		_progress = 0.0
		_rotate_right()

func _rotate_left():
	emit_signal("rotation_start")
	_rotating = true
	_rotation_index += -1
	_rotation_index %= _rotations.size()

func _rotate_right():
	emit_signal("rotation_start")
	_rotating = true
	_rotation_index += 1
	_rotation_index %= _rotations.size()

func get_offset():
	var g_origin = $Camera.get_global_transform().origin
	#print("g_origin: " + var2str(g_origin / g_origin.abs()))
	return (g_origin / g_origin.abs()).round()

