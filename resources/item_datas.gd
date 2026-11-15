extends Resource

class_name ItemDatas

@export var datas : Array[ItemData]

func find(n : String):
	for i in datas.size():
		if datas[i].name == n:
			return i
	return -1

func setup():
	for i in datas.size():
		datas[i].dummy.setup(i)
