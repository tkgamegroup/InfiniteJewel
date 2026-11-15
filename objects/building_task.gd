extends RefCounted

class_name BuildingTask

var id : int
var progress : int = 0
var duration : int = 1
var channeling : Channeling = Channeling.new()

func advance():
	var sp = 1
	if G.debug_ui.fast_produce:
		sp *= 10
	progress += sp
	return sp
