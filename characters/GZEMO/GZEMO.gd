extends Spatial

onready var _shade = Color(1,1,1,1) setget set_shade, get_shade
onready var level_root = get_parent()
onready var cam_root = get_node("../CameraRoot")
onready var cam = cam_root.get_node("Camera")
onready var _last_position = get_translation()
onready var meshes = get_node("Meshes")

var _color_locations

var _walk_speed = 0.15
var _walk_progress = 0.0

func _ready():
	set_translation(level_root.get_node("SpawnPoint").get_translation())
	set_process(true)
	set_shade(_shade)

func _process(delta):
	_walk_progress += delta
	if _walk_progress > _walk_speed:
		_walk_progress = 0.0
		_last_position = get_translation()
		_check_input()

func walk():
	if $AnimationPlayer.current_animation != "Walk":
		$AnimationPlayer.play("Walk")

func idle():
	if $AnimationPlayer.current_animation != "Idle":
		$AnimationPlayer.play("Idle")

func jump():
	$AnimationPlayer.play("Walk", -1, 0.0)
	$AnimationPlayer.seek(0.25, true)

func _check_input():
	var v = get_node("../ColorTiles").world_to_map(get_translation())
	
	var input_vector = Vector3()
	if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_up"):
		input_vector = Vector3(-1,0,0)
	elif Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_down"):
		input_vector = Vector3(0,0,1)
	elif Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_up"):
		input_vector = Vector3(0,0,-1)
	elif Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_down"):
		input_vector = Vector3(1,0,0)
	else:
		idle()
		#return
	input_vector = input_vector.rotated(Vector3(0,1,0), deg2rad(cam_root.get_rotation_index() * 90))
	input_vector = input_vector.round()
	
	var t = meshes.get_global_transform()
	
	if input_vector.length() != 0:
		t = t.looking_at(
			t.origin - input_vector, \
			Vector3(0,1,0)
		)
	meshes.set_global_transform(t)
	
	#assert(input_vector.z == 0)
	var result = level_root.check_can_move(v+input_vector, _shade)
	if result.can_move:
		walk()
		var l = result.flat
		_color_locations = result.color_locations
		set_translation(get_node("../ColorTiles").map_to_world(l.x, l.y, l.z))
		Beep.stop()
	else:
		if input_vector.length() > 0:
			Beep.pitch_scale = 1.0
			Beep.play(0)
		else:
			Beep.pitch_scale = 0.25
			Beep.play(0)
		_color_locations = result.color_locations
		idle()

func set_shade(shade):
	_shade = shade
	get_node("Meshes/MeshInstance").get_surface_material(0).set("albedo_color", _shade)
	get_node("Meshes/MeshInstance2").get_surface_material(0).set("albedo_color", _shade)
	get_node("Meshes/MeshInstance3").get_surface_material(0).set("albedo_color", _shade)

func get_shade():
	return _shade

func _on_CameraRoot_rotation_end():
	pass


func _on_CameraRoot_rotation_start(direction):
	assert(_color_locations != null)
	
	var rp
	if _color_locations.size() == 0:
		print("_color_locations.size() was 0")
	else:
		match(direction):
			0: rp = _color_locations.front()
			1: rp = _color_locations.back()
	if rp:
		set_translation(get_node("../ColorTiles").map_to_world(rp.x, rp.y, rp.z))
	
	meshes.set_global_transform(get_global_transform())
