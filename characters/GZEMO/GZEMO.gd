extends Spatial

onready var _shade = Color(1,1,1,1) setget set_shade, get_shade
onready var level_root = get_parent()
onready var cam_root = get_node("../CameraRoot")
onready var cam = cam_root.get_node("Camera")
onready var _last_position = get_translation()
onready var meshes = get_node("Meshes")
#var _ci = 0
var _real_position

var _walk_speed = 0.15
var _walk_progress = 0.0

func _ready():
	set_translation(level_root.get_node("SpawnPoint").get_translation())
	set_process(true)
	set_shade(_shade)
	_pull_towards_cam()

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
		return
	input_vector = input_vector.rotated(Vector3(0,1,0), deg2rad(cam_root.get_rotation_index() * 90))
	input_vector = input_vector.round()
	
	var t = meshes.get_global_transform()
	
	t = t.looking_at(
		t.origin - input_vector, \
		Vector3(0,1,0)
	)
	meshes.set_global_transform(t)
	var v = get_node("../ColorTiles").world_to_map(get_translation())
	var result = level_root.check_can_move(v+input_vector, _shade)
	if result.can_move:
		walk()
		if result.color_locations.size() > 1:
			breakpoint
		var l = result.flat
		_real_position = result.color_locations.front()
		#print("l: " + var2str(l))
		set_translation(get_node("../ColorTiles").map_to_world(l.x, l.y, l.z))
	else:
		idle()
		#print("couldn't move")

func set_shade(shade):
	_shade = shade
	get_node("Meshes/MeshInstance").get_surface_material(0).set("albedo_color", _shade)
	get_node("Meshes/MeshInstance2").get_surface_material(0).set("albedo_color", _shade)
	get_node("Meshes/MeshInstance3").get_surface_material(0).set("albedo_color", _shade)

func get_shade():
	return _shade

func _pull_towards_cam():
	var t = get_global_transform()
	t.origin += cam_root.get_offset() * 20
	t.basis = meshes.get_global_transform().basis
	#
	meshes.set_global_transform(t)
	#

func _on_CameraRoot_rotation_end():
	_pull_towards_cam()


func _on_CameraRoot_rotation_start():
	if (_real_position):
		set_translation(get_node("../ColorTiles").map_to_world(_real_position.x, _real_position.y, _real_position.z))
	meshes.set_global_transform(get_global_transform())
