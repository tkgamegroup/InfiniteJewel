extends Resource

class_name Spells

@export var datas : Array[Spell]

func find(n : String):
	for i in datas.size():
		if datas[i].name == n:
			return i
	return -1

func find_data(n : String):
	var idx = find(n)
	return datas[idx]
