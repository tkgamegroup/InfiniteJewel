extends Resource

class_name Talent

const type_name : StringName = &"Talent"

@export var row : int
@export var column : int
@export var name : String
@export var description : String
@export var max_lv : int = 1
@export var costs : Array[int]
@export var dependency : String
@export var spell_name : String

var spell : Spell
var lv : int = 0

var ui : UiTalent = null

func add_points(v : int):
	v = min(v, max_lv - lv)
	if v > 0:
		spell.revert(self, [])
		lv += v
		spell.apply(self, [], lv)
		G.talent_tree.update_spent_points()

func is_max_lv():
	return lv >= max_lv

func next_lv_cost():
	if is_max_lv():
		return 0
	if costs.is_empty():
		return 0
	return costs[lv]

func is_prerequisites_met():
	if row > 0 && G.talent_tree.spent_points[row - 1] < 5:
		return false
	if !dependency.is_empty():
		var dep = G.talent_tree.find_data(dependency)
		if dep && dep.lv == 0:
			return false
	return true

func get_description(lv : int) -> String:
	if lv == -1:
		lv = self.lv
	var ret = description + "\n" + G.format_description(spell.description, spell, lv)
	return ret.trim_prefix("\n").trim_suffix("\n")
