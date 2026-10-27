extends RefCounted

class_name Cell

var gem : Gem = null
var item : Item = null

func is_empty() -> bool:
	return !gem && !item
