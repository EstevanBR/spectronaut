extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var grid = $GridMap
onready var grid_wrap_size = Vector3(32,32,32)

var loop = 0.1
var progress = 0.0
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process_input(false)
	set_process(true)
	pass

func _process(delta):
	return
	progress += delta
	if progress > loop:
		progress = 0
		_check()

func _check():
	var shift_vector = Vector3()
	if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_up"):
		shift_vector = Vector3(-1,0,0)
	if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_down"):
		shift_vector = Vector3(0,0,1)
	if Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_up"):
		shift_vector = Vector3(0,0,-1)
	if Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_down"):
		shift_vector = Vector3(1,0,0)
	#shift_vector = shift_vector.rotated(Vector3(0,1,0), deg2rad(45)).normalized()
	print("shift: " + var2str(shift_vector))
	_shift(shift_vector)
	
func _shift(shift_vector):
	var cursor = Vector3(1,1,1)
	# get tiles
	var tiles = grid.get_used_cells()
	
	grid.clear()
	var cells = {}
	
	for cell in tiles:
#		grid.set_cell_item(cell.x, cell.y, cell.z, cell_id)
		var cell_id = grid.get_cell_item(cell.x, cell.y, cell.z)
		#var new_cell_position = Vector3(cell.x, cell.y, cell.z)
		if true:#cell.x == cursor.x || cell.y == cursor.y || cell.z == cursor.z:
			cell += shift_vector
		cell.x = wrapi(cell.x, -grid_wrap_size.x, grid_wrap_size.x)
		cell.y = wrapi(cell.y, -grid_wrap_size.y, grid_wrap_size.y)
		cell.z = wrapi(cell.z, -grid_wrap_size.z, grid_wrap_size.z)
		#cell.x = int(fmod(cell.x, grid_wrap_size.x)) * int()
		#new_tiles.push_back(Vector3(cell.x, cell.y, cell.z))
		grid.set_cell_item(cell.x, cell.y, cell.z, 0)