extends Effect

class_name EfDestroySelf

func excute(caster):
	var i = caster as Item
	G.dead_cells[i.coord] = 1
