extends Spatial

#const CellWithOrientation = preload("res://CellWithOrientation.gd")

export(String) var _next_level_name

signal level_completed

var progress = 0

class CanMoveResult:
	func _init(l, f = null, n = null):
	#func _init(l, m, f):
		color_locations = l
		#can_move = m
		flat = f
		neighbors = n
	var color_locations
	#var can_move
	var flat
	var neighbors

onready var cam_root = $CameraRoot

#var cells = null
export(Color) var shade

func _ready():
	set_process(true)
	set_process_input(true)
	get_node("GZEMO").set_shade(shade)
	connect("level_completed", LevelSwitcher, "_on_level_complete")
	assert(shade != null)

func _process(delta):
	pass

# takes a vector 3 which is the cell index for the next desired position
func check_can_move(v, source_color):
	var can_move = false
	var dest_color = null
	var off = cam_root.get_offset()
	
	var cells = $ColorTiles.get_filtered() #.flattened_to_z(off, v.z)
	var flat_cells = cells.cells_flattened_to_y(off, v.y)
	
	var noffs = [
		Vector3( 1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3( 0, 0, 1),
		Vector3( 0, 0,-1)
	]
	
	var neighbors = {}
	for noff in noffs:
		var vnoff = v + noff
		if flat_cells.has(vnoff) && _can_move(source_color, flat_cells[v+noff]):
			neighbors[noff] = flat_cells[vnoff]
	
	if flat_cells.has(v):
		#print("flat_cells[" + var2str(v) + "]: " + var2str(flat_cells[v]))
		dest_color = flat_cells[v]
	if dest_color == Color(-1,-1,-1):
		emit_signal("level_completed", name, _next_level_name)
		dest_color = Color(1,1,1)
	#can_move = _can_move(source_color, dest_color)
	
	#return CanMoveResult.new([v], can_move)
	var congruent_positions = cells.congruent_positions_at(v, off)
	var flat = cells.cell_flattened_to_y(v, off, v.y)
	#var neighbors = []
	#
#	if flat_cells.has(v + Vector3(-1,0,0)):
#		neighbors.append(v + Vector3(-1,0,0))
#	if flat_cells.has(v + Vector3(1,0,0)):
#		neighbors.append(v + Vector3(1,0,0))
#	if flat_cells.has(v + Vector3(0,0,1)):
#		neighbors.append(v + Vector3(0,0,1))
#	if flat_cells.has(v + Vector3(0,0,-1)):
#		neighbors.append(v + Vector3(0,0,-1))
	#
	return CanMoveResult.new(congruent_positions, flat, neighbors)

func _can_move(from, to):
	to = Color(abs(to.r), abs(to.g), abs(to.b))
	return to != null && to.r >= from.r && to.g >= from.g && to.b >= from.b

func _input(event):
	if event.is_action_pressed("print_cam_offset"):
		#print (var2str(cam_root.get_offset()))
		pass