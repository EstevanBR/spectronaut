tool
extends Camera

export(float) var _time = 1.0
var _progress = 0.0

export(int) var _index = 0 setget set_index

func _ready():
	if Engine.editor_hint == false:
		queue_free()
	else:
		set_process(true)

func _process(delta):
	_progress += delta
	if _progress >= _time:
		_progress = 0
		set_index(_index + 1)

func set_index(i):
	_index = i % 4
	if Engine.editor_hint == false:
		return
	match _index:
		0: set_global_transform(get_node("../CameraRoot/Camera").get_global_transform())
		1: set_global_transform(get_node("../CameraRoot/Camera2").get_global_transform())
		2: set_global_transform(get_node("../CameraRoot/Camera3").get_global_transform())
		3: set_global_transform(get_node("../CameraRoot/Camera4").get_global_transform())