extends Spatial

var progress = 0

onready var red_tiles =   get_node("RedGridMap")
onready var blue_tiles =  get_node("BlueGridMap")
onready var green_tiles = get_node("GreenGridMap")

func _ready():
	set_process(true)
	set_process_input(true)

func _process(delta):
	progress += delta
	
	red_tiles.set_translation(Vector3(sin(progress * 1.1),0,cos(progress * 1.1)))
	blue_tiles.set_translation(Vector3(sin(progress * 1.2),0,cos(progress * 1.2)))
	green_tiles.set_translation(Vector3(sin(progress),0,cos(progress)))
	$GZEMO.rotate_y(delta)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to(load("res://Level0.tscn"))