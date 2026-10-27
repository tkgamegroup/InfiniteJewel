extends StatBlock

class_name Pattern

var coords : Array[Vector3i]

func match_with(off : Vector2i):
	var ret = []
	var c_off = G.offset_to_cube(off)
	var first_color = G.Colors.None
	for c in coords:
		var oc = G.cube_to_offset(c_off + c)
		if !G.is_valid_coord(oc):
			return []
		var g = G.cells[oc].gem
		if !g:
			return []
		if first_color == G.Colors.None:
			first_color = g.color
		elif g.color != first_color:
			return []
		ret.append(oc)
	return ret

func setup(_coords : Array[Vector3i]):
	coords = _coords
	init_attributes({"Damage":1})
