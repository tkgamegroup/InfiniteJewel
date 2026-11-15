extends Effect

class_name EfExplode

func excute(caster):
	var i = caster as Item
	for c in G.offset_within(i.coord, i.get_attr(&"range")):
		if G.is_valid_coord(c):
			G.take_damage(c, i.get_attr(&"power"), false)
