extends Spatial

signal gzemo_shade_changed(shade)

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
	emit_signal("gzemo_shade_changed")

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
	var result = level_root.check_can_move(v, _shade)
	_color_locations = result.color_locations
	
	var input_vector = Vector3()
	if Input.is_action_pressed("ui_left"):# && Input.is_action_pressed("ui_up"):
		input_vector += Vector3(-1,0,0)
	if Input.is_action_pressed("ui_right"):# && Input.is_action_pressed("ui_down"):
		input_vector += Vector3(1,0,0)
	if Input.is_action_pressed("ui_up"):# && Input.is_action_pressed("ui_up"):
		input_vector += Vector3(0,0,-1)
	if Input.is_action_pressed("ui_down"):# && Input.is_action_pressed("ui_down"):
		input_vector += Vector3(0,0,1)
	if input_vector.length() == 0:
		idle()
		return
	input_vector = input_vector.rotated(Vector3(0,1,0), deg2rad(( cam_root.get_rotation_index() * 90) + 45) )
	input_vector = input_vector.round()
	
	#var rotated_neighbors = result.neighbors#.rotated(Vector3(0,1,0), deg2rad(cam_root.get_rotation_index() * 90))
#	if input_vector.length() > 0:
#		print("               v: " + var2str(v))
#		print("    input_vector: " + var2str(input_vector))
#		print("  v+input_vector: " + var2str(v+input_vector))
#		print("result.neighbors: " + var2str(result.neighbors))
#		print("\n")
	#breakpoint
	var cardinal_input = input_vector.rotated(Vector3(0,1,0), deg2rad(-45)).round()
	print("\n")
	if [Vector3(1,0,0),Vector3(-1,0,0),Vector3(0,0,1),Vector3(0,0,-1)].has(cardinal_input):
		for n in result.neighbors:
			var rotated_neighbor = n.rotated(Vector3(0,1,0), deg2rad(-45)).round()
			#print("rotated_neighbor: " + var2str(rotated_neighbor))
			#print("  cardinal_input: " + var2str(cardinal_input))
			#result
			#breakpoint
			if (rotated_neighbor.x == cardinal_input.x && cardinal_input.x != 0) \
			|| (rotated_neighbor.z == cardinal_input.z && cardinal_input.z != 0):
				input_vector = rotated_neighbor.rotated(Vector3(0,1,0), deg2rad(45)).round()
				break
			pass
		
		#print("cardinal: " + var2str(cardinal.round()))
		#breakpoint
	var t = meshes.get_global_transform()
	
	if input_vector.length() == 1:
		t = t.looking_at(
			t.origin - input_vector, \
			Vector3(0,1,0)
		)
	meshes.set_global_transform(t)
	
	#assert(input_vector.z == 0)
	#var result = level_root.check_can_move(v, _shade)
	if result.neighbors.has(input_vector):#input_vector.length() == 0:
		walk()
		var l = v+input_vector
		#_color_locations = result.color_locations
		set_translation(get_node("../ColorTiles").map_to_world(l.x, l.y, l.z))
		Beep.stop()
	else:
		if input_vector.length() > 0:
			Beep.pitch_scale = 1.0
			Beep.play(0)
		else:
			Beep.pitch_scale = 0.25
			Beep.play(0)
		#_color_locations = result.color_locations
		idle()

func set_shade(shade):
	_shade = shade
	get_node("Meshes/MeshInstance").get_surface_material(0).set("albedo_color", _shade)
	get_node("Meshes/MeshInstance2").get_surface_material(0).set("albedo_color", _shade)
	get_node("Meshes/MeshInstance3").get_surface_material(0).set("albedo_color", _shade)
	emit_signal("gzemo_shade_changed", _shade)

func get_shade():
	return _shade

func _on_CameraRoot_rotation_end():
	pass


func _on_CameraRoot_rotation_start(direction):
	if _color_locations == null:
		var v = get_node("../ColorTiles").world_to_map(get_translation())
		var result = level_root.check_can_move(v, _shade)
		_color_locations = result.color_locations
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
