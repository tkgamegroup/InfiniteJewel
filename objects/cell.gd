extends RefCounted

class_name Cell

var gem : Gem = null
var item : Item = null
var auras : Array[Vector2i]

func is_empty() -> bool:
	return !gem && !item
