extends Spatial

onready var level_root = get_parent()
onready var cam = get_parent().get_node("CameraRoot/Camera")

var _walk_speed = 0.1
var _walk_progress = 0.0

func _ready():
	set_translation(level_root.get_node("SpawnPoint").get_translation())
	set_process(true)

func _process(delta):
	_walk_progress += delta
	if _walk_progress > _walk_speed:
		_walk_progress = 0.0
		_check_input(delta)

func walk():
	$AnimationPlayer.play("Walk")

func idle():
	$AnimationPlayer.play("Idle")

func jump():
	$AnimationPlayer.play("Walk", -1, 0.0)
	$AnimationPlayer.seek(0.25, true)

func _check_input(delta):
	var input_vector = Vector3()
	if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_up"):
		input_vector = Vector3(1,0,0)
	if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_down"):
		input_vector = Vector3(0,0,-1)
	if Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_up"):
		input_vector = Vector3(0,0,1)
	if Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_down"):
		input_vector = Vector3(-1,0,0)
	_move(input_vector, delta)

func _move(input_vector, delta):
	var tile_position = get_node("../RedGridMap").world_to_map(get_translation())
	print(var2str(tile_position))
	translate(input_vector * delta * 64.0)
	#breakpoint