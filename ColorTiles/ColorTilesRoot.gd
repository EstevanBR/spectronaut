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
	var red = []
	var green = []
	var blue = []
	var white = []
	var rainbow = []
	var magenta = []
	var cyan = []
	var yellow = []
	
	func as_dict():
		return {
			RED:red,
			GREEN:green,
			BLUE:blue,
			WHITE:white,
			RAINBOW:rainbow,
			MAGENTA: magenta,
			CYAN:cyan,
			YELLOW:yellow
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
					RED:
						colors[flat_cell].r = 1
						if flattened.green.has(flat_cell):
							flattened.yellow.append(flat_cell)
						elif flattened.blue.has(flat_cell):
							flattened.magenta.append(flat_cell)
						else:
							flattened.red.append(flat_cell)
					GREEN:
						colors[flat_cell].g = 1
						if flattened.blue.has(flat_cell):
							flattened.cyan.append(flat_cell)
						elif flattened.red.has(flat_cell):
							flattened.yellow.append(flat_cell)
						else:
							flattened.green.append(flat_cell)
					BLUE:
						colors[flat_cell].b = 1
						if flattened.red.has(flat_cell):
							flattened.magenta.append(flat_cell)
						elif flattened.green.has(flat_cell):
							flattened.cyan.append(flat_cell)
						else:
							flattened.blue.append(flat_cell)
					WHITE:
						colors[flat_cell] = Color(1,1,1)
						flattened.white.append(flat_cell)
					RAINBOW:
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
					RED:     position.red.append(c)
					GREEN:   position.green.append(c)
					BLUE:    position.blue.append(c)
					WHITE:   position.white.append(c)
					RAINBOW: position.rainbow.append(c)
					MAGENTA: position.magenta.append(c)
					CYAN:    position.cyan.append(c)
					YELLOW:  position.yellow.append(c)
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
			WHITE:   filtered.white.append(cell)
			RED:     filtered.red.append(cell)
			GREEN:   filtered.green.append(cell)
			BLUE:    filtered.blue.append(cell)
			RAINBOW: filtered.rainbow.append(cell)
			MAGENTA: filtered.magenta.append(cell)
			CYAN:    filtered.cyan.append(cell)
			YELLOW:  filtered.yellow.append(cell)
			_: assert(false)
	return filtered



func _on_CameraRoot_rotation_end():
	set_visible(false)
	pass

func _on_CameraRoot_rotation_start(direction):
	set_visible(true)
	pass
