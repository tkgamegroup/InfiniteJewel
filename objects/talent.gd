extends Resource

class_name Talent

@export var row : int
@export var column : int
@export var lv : int
@export var max_lv : int = 1
@export var modifiers : Array[ModifierTarget]
@export var description : String

func apply():
	for m in modifiers:
		for t in m.get_targets():
			if m.type == Modifier.Type.Switch:
				t.attributes[m.target_attribute].switch(1)
			else:
				t.add_mod(m.target_attribute, self, m.type, m.base_value + m.value_per_lv * lv, 900, 0)

func revert():
	for m in modifiers:
		for t in m.get_targets():
			if m.type == Modifier.Type.Switch:
				t.attributes[m.target_attribute].switch(0)
			else:
				t.remove_mod(m.target_attribute, self)

func add_points(v : int):
	if v > 0:
		v = min(v, max_lv - lv)
		revert()
		lv += v
		apply()
