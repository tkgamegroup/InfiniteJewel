extends RefCounted

class_name Building

var is_enable : bool = false
var products : Array[Item]
## name, ticks, total ticks
var producing : Array = []

var ui : UiBuilding = null

func enable():
	if is_enable:
		return
	is_enable = true
	ui.show()
	ui.timer.start()

func add_producing(product_idx : int):
	if products.size() <= product_idx:
		return
	var i = products[product_idx]
	producing = [i.name, 0, i.produce_ticks]
