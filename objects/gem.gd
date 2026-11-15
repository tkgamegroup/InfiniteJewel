extends StatBlock

class_name Gem

const type_name : StringName = &"Gem"
const name : String = ""
const category : StringName = &""

static var dummy : Gem = Gem.new()

var color : int
var durability : int

func _init() -> void:
	init_attributes({&"max_durability":1,&"value":0})

func setup(_color : int, max_durability : int, value : int):
	color = _color
	durability = max_durability
	attributes[&"max_durability"].base_value = max_durability
	attributes[&"value"].base_value = value
	dummy.transfer_born_stats(self)
