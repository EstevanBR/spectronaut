extends GridMap

#const CellWithOrientation = preload("res://CellWithOrientation.gd")

enum COLORS {
	WHITE,
	RED,
	GREEN,
	BLUE,
	RAINBOW,
	MAGENTA,
	CYAN,
	YELLOW
}

class PositionSort:
	static func sort(a,b):
		return a.y > b.y

class FilteredCells:
# warning-ignore:unused_class_variable
	var red = []
# warning-ignore:unused_class_variable
	var green = []
# warning-ignore:unused_class_variable
	var blue = []
# warning-ignore:unused_class_variable
	var white = []
# warning-ignore:unused_class_variable
	var rainbow = []
# warning-ignore:unused_class_variable
	var magenta = []
# warning-ignore:unused_class_variable
	var cyan = []
# warning-ignore:unused_class_variable
	var yellow = []
	
	func as_dict():
		return {
			COLORS.RED:red,
			COLORS.GREEN:green,
			COLORS.BLUE:blue,
			COLORS.WHITE:white,
			COLORS.RAINBOW:rainbow,
			COLORS.MAGENTA: magenta,
			COLORS.CYAN:cyan,
			COLORS.YELLOW:yellow
		}
	func cell_flattened_to_y(v, o, y):
		var y_off = v.y - y
		var flat_cell = v - (o * y_off * sign(o.y))
		
		#print("flat_cell: " + var2str(flat_cell))
		
		return flat_cell
	func cells_flattened_to_y( off, y ):
		var flattened = get_script().new()
		var colors = {}
		
		for letter in as_dict():
			for cell in as_dict()[letter]:
				#var z_off = cell.z - z
				var flat_cell = cell_flattened_to_y(cell, off, y)
				#flat_cell = flat_cell.round()
				if !colors.has(flat_cell):
					colors[flat_cell] = Color()
				
				match letter:
					COLORS.RED:
						colors[flat_cell].r = 1
						if flattened.green.has(flat_cell):
							flattened.yellow.append(flat_cell)
						elif flattened.blue.has(flat_cell):
							flattened.magenta.append(flat_cell)
						else:
							flattened.red.append(flat_cell)
					COLORS.GREEN:
						colors[flat_cell].g = 1
						if flattened.blue.has(flat_cell):
							flattened.cyan.append(flat_cell)
						elif flattened.red.has(flat_cell):
							flattened.yellow.append(flat_cell)
						else:
							flattened.green.append(flat_cell)
					COLORS.BLUE:
						colors[flat_cell].b = 1
						if flattened.red.has(flat_cell):
							flattened.magenta.append(flat_cell)
						elif flattened.green.has(flat_cell):
							flattened.cyan.append(flat_cell)
						else:
							flattened.blue.append(flat_cell)
					COLORS.WHITE:
						colors[flat_cell] = Color(1,1,1)
						flattened.white.append(flat_cell)
					COLORS.RAINBOW:
						colors[flat_cell] = Color(-1,-1,-1)
						flattened.rainbow.append(flat_cell)
					_:
						pass#assert(false)
		for c in colors:
			assert(c.y == y)
		return colors
		
	func at_position(v):
		var d = as_dict()
		var position = get_script().new()
		for l in d:
			var c = d[l].find(v)
			if c != -1:
				match l:
					COLORS.RED:     position.red.append(c)
					COLORS.GREEN:   position.green.append(c)
					COLORS.BLUE:    position.blue.append(c)
					COLORS.WHITE:   position.white.append(c)
					COLORS.RAINBOW: position.rainbow.append(c)
					COLORS.MAGENTA: position.magenta.append(c)
					COLORS.CYAN:    position.cyan.append(c)
					COLORS.YELLOW:  position.yellow.append(c)
		return position
	func congruent_positions_at(v, off):
		var positions = []
		#positions.append(v)
		var dict = as_dict()
		for key in dict:
			for cell in dict[key]:
				var depth = v.y - cell.y
				if cell + (off * depth) == v && positions.has(cell) == false:
					positions.append(cell)
				if cell + (off * -depth) == v && positions.has(cell) == false:
					positions.append(cell)
		positions.sort_custom(PositionSort.new(), 'sort')
		return positions

func _ready():
	set_visible(false)

func get_filtered(cells = []):
	var filtered = FilteredCells.new()

	if cells == []:
		cells = get_used_cells()

	for cell in cells:
		cell = cell.round()
		var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
		if orientation != 0:
			continue
		match get_cell_item(cell.x, cell.y, cell.z):
			COLORS.WHITE:   filtered.white.append(cell)
			COLORS.RED:     filtered.red.append(cell)
			COLORS.GREEN:   filtered.green.append(cell)
			COLORS.BLUE:    filtered.blue.append(cell)
			COLORS.RAINBOW: filtered.rainbow.append(cell)
			COLORS.MAGENTA: filtered.magenta.append(cell)
			COLORS.CYAN:    filtered.cyan.append(cell)
			COLORS.YELLOW:  filtered.yellow.append(cell)
			_: assert(false)
	return filtered



func _on_CameraRoot_rotation_end():
	set_visible(false)
	pass

# warning-ignore:unused_argument
func _on_CameraRoot_rotation_start(direction):
	set_visible(true)
	pass
