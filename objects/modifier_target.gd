extends Resource

class_name ModifierTarget

@export var target_type : StringName
@export var target_name : String
@export var target_attribute : StringName
@export var type : Modifier.Type
@export var base_value : int
@export var value_per_lv : int
@export var priority : int
@export var category : int

func get_targets() -> Array[StatBlock]:
	var ret : Array[StatBlock] = []
	match target_type:
		&"Game":
			ret.append(G.stats)
		&"Pattern":
			for p in G.patterns:
				ret.append(p)
	return ret
