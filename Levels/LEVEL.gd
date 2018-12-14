extends Spatial

#const CellWithOrientation = preload("res://CellWithOrientation.gd")

export(String) var _next_level_name

signal level_completed

var progress = 0

class CanMoveResult:
	func _init(l, m = false, o = null):
		color_locations = l
		can_move = m
	var color_locations = []
	var can_move = false

onready var cam_root = $CameraRoot

#var cells = null
export(Color) var shade

func _ready():
	set_process(true)
	set_process_input(true)
	get_node("GZEMO").set_shade(shade)
	connect("level_completed", LevelSwitcher, "_on_level_complete")
	$ColorTiles.set_visible(false)
	assert(shade != null)

func _process(delta):
	pass

# takes a vector 3 which is the cell index for the next desired position
func check_can_move(v, source_color):
	var can_move = false
	var dest_color = Color(0,0,0)
	var off = cam_root.get_offset()
	
	var cells = $ColorTiles.get_filtered() #.flattened_to_z(off, v.z)
	
	for i in range(-20,20):
		#var voff = CellWithOrientation.new(v + (off * -i), 0)
		var voff = v + (off * -i)
		
		if dest_color.r < 0.01 \
		&& cells.red.find(voff) != -1:
			dest_color.r = 1
		
		if dest_color.g < 0.01 \
		&& cells.green.find(voff) != -1:
			dest_color.g = 1
		
		if dest_color.b < 0.01 \
		&& cells.blue.find(voff) != -1:
			dest_color.b = 1
		
		if cells.white.find(voff) != -1:
			dest_color = Color(1,1,1)
		
		if cells.rainbow.find(voff) != -1:
			dest_color = Color(1,1,1)
			emit_signal("level_completed", name, _next_level_name)
			#assert(false)
	can_move = dest_color.r >= source_color.r && dest_color.g >= source_color.g && dest_color.b >= source_color.b
	
	#return CanMoveResult.new([v], can_move)
	var congruent_positions = cells.congruent_positions_at(v, off)
	return CanMoveResult.new(congruent_positions, can_move)

func _input(event):
	if event.is_action_pressed("print_cam_offset"):
		#print (var2str(cam_root.get_offset()))
		pass