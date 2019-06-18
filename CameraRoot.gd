extends Spatial

signal rotation_start
signal rotation_end

var _t

var _rotating = false
func rotating():
	return _rotating

var _filter_color setget set_filter_color,get_filter_color

func set_filter_color(color):
	_filter_color = color
	#$Camera.get_node("ColorRect").material.set_shader_param("filter_color", _filter_color)

func get_filter_color():
	return _filter_color

var _rotations = [
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*0) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*1) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*2) % 360 ))),
				 Transform(Quat(Vector3(0,1,0), deg2rad((90*3) % 360 )))
				]

var _rotation_speed = 0.15
var _progress = _rotation_speed

var _rotation_index = 0
func get_rotation_index():
	return _rotation_index
#func get_rotation_from_index(index = 0):
#	index = index % 4
#	return _rotations[index]

func _ready():
	#get_node("../GZEMO").connect("gzemo_shade_changed", self, "_on_GZEMO_gzemo_shade_changed")
	set_process_input(true)
	set_process(true)
	set_transform(_rotations[_rotation_index])
	$Camera2.queue_free()
	$Camera3.queue_free()
	$Camera4.queue_free()
	
# warning-ignore:return_value_discarded
	connect("rotation_start", self, "_on_rotation_start")
# warning-ignore:return_value_discarded
	connect("rotation_end", self, "_on_rotation_end")
	set_filter_color(_filter_color)

func _process(delta):
	_progress += delta
	if _progress < _rotation_speed:
		#var t = get_transform()
		if (_t == null):
			_t = get_transform()
		var s = Quat(_rotations[_rotation_index].basis)
		var ratio = clamp(_progress / _rotation_speed, 0, 1.0)
		var slerpd = Quat(_t.basis).slerp(s, ratio)
		Music.pitch_scale = min(1.0, ratio + 0.5)
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
	emit_signal("rotation_start", 0)
	_rotating = true
	_rotation_index += -1
	_rotation_index %= _rotations.size()

func _rotate_right():
	emit_signal("rotation_start", 1)
	_rotating = true
	_rotation_index += 1
	_rotation_index %= _rotations.size()

func get_offset():
	var g_origin = $Camera.get_global_transform().origin
	#print("g_origin: " + var2str(g_origin / g_origin.abs()))
	return (g_origin / g_origin.abs()).round()

# warning-ignore:unused_argument
func _on_rotation_start(direction):
	_t = get_transform()

func _on_rotation_end():
	_t = null

func _on_GZEMO_gzemo_shade_changed(shade):
	set_filter_color(shade)
