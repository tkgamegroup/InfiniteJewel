extends Resource

class_name Technology

const type_name : StringName = &"Tech"

@export var name : String
@export var description : String
@export var spell_name : String

var spell : Spell
var acquired : bool = false

func acquire():
	if acquired:
		return
	acquired = true
	spell.apply(self, [], 1)

func get_description(lv : int) -> String:
	if lv == -1:
		lv = 0
	var ret = description + "\n" + G.format_description(spell.description, spell, lv)
	return ret.trim_prefix("\n").trim_suffix("\n")
