#
# v = Vector3
# o = Vector3 (all values either 1 or -1)
# z = integer
#
func cell_flattened_to_z(v, o, z):
	var z_off = v.z - z
	var flat_cell = v - (o * z_off * sign(o.z))
	return flat_cell