extends RefCounted

class_name Item

var res_id : int = -1
var name : String
var image_id : int
var produce_ticks : int = 10
var max_stack : int = 1
var power : int
var effect_range : int

var coord : Vector2i
var ticks : int

var on_event : Callable

func setup(n : String):
	name = n
	if name == "Bomb":
		res_id = 1
		image_id = 6
		produce_ticks = 300
		max_stack = 3
		power = 40
		effect_range = 1
		on_event = func(ev : String):
			if ev == "tick":
				ticks += 1
				if ticks >= 30:
					for c in G.offset_within(coord, effect_range):
						if c != coord:
							if G.is_valid_coord(c):
								G.take_damage(c, power)
					G.dead_cells[coord] = 1
	elif name == "Flag":
		res_id = 2
		image_id = 7
		produce_ticks = 300
		max_stack = 3
		effect_range = 2
