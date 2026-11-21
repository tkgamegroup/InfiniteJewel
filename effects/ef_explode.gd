extends Effect

class_name EfExplode

func excute(caster):
	var i = caster as Item
	for c in G.offset_within(i.coord, i.get_attr(&"range")):
		if G.is_valid_coord(c):
			G.take_damage(c, i.get_attr(&"power"), false)
			if !G.dead_cells.has(c):
				var ti = G.cells[c].item
				if ti:
					for s in ti.spells:
						for e in s.exploded_trigger_effects:
							e.excute(ti)
