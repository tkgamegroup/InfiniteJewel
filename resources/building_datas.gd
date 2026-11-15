extends Resource

class_name BuildingDatas

@export var datas : Array[BuildingData]

func find(n : String):
	for i in datas.size():
		if datas[i].name == n:
			return i
	return -1

func setup():
	for d in datas:
		for p in d.products:
			match p.type_name:
				&"Item": p.id = G.item_datas.find(p.name)
				&"Tech": p.id = G.technologies.find(p.name)
				&"Spell": p.id = G.spells.find(p.name)
			assert(p.id != -1)
