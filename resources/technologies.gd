extends Resource

class_name Technologies

@export var datas : Array[Technology]

func find(n : String):
	for i in datas.size():
		if datas[i].name == n:
			return i
	return -1

func setup():
	for t in datas:
		t.spell = G.spells.find_data(t.spell_name)
		assert(t.spell)
