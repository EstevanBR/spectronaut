extends GridMap

#const CellWithOrientation = preload("res://CellWithOrientation.gd")

enum COLORS {
	WHITE,
	RED,
	GREEN,
	BLUE,
	RAINBOW,
	MAGENTA,
	YELLOW,
	CYAN
}

onready var color_tiles_unflattened = get_node("../ColorTiles")
onready var cam_root = get_node("../CameraRoot")
onready var gzemo = get_node("../GZEMO")

func _ready():
	_fill()

func _on_CameraRoot_rotation_end():
	_fill()

func _on_CameraRoot_rotation_start():
	clear()

func _fill():
	var flattened = color_tiles_unflattened.get_filtered().flattened_to_z(
		cam_root.get_offset(),
		color_tiles_unflattened.world_to_map( gzemo.get_translation() ).z
	)#.as_dict()
	for pos in flattened:
		var color = flattened[pos]
		var id = -1
		match color:
			Color(1,0,0):
				id = COLORS.RED
			Color(0,1,0):
				id = COLORS.GREEN
			Color(0,0,1):
				id = COLORS.BLUE
			Color(1,1,0):
				id = COLORS.YELLOW
			Color(0,1,1):
				id = COLORS.CYAN
			Color(1,0,1):
				id = COLORS.MAGENTA
			Color(1,1,1):
				id = COLORS.WHITE
			Color(-1,-1,-1):
				id = COLORS.RAINBOW
		#breakpoint
		set_cell_item(pos.x, pos.y, pos.z, id)
	for cell in color_tiles_unflattened.get_used_cells():
		var o = color_tiles_unflattened.get_cell_item_orientation(cell.x, cell.y, cell.z)
		if o != 0 && o != -1:
			set_cell_item(cell.x, cell.y, cell.z, color_tiles_unflattened.get_cell_item(cell.x, cell.y, cell.z), o)