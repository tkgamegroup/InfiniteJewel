extends Resource

class_name TalentTree

@export var tree : Array[Talent]

var spent_points : Array[int]

func find(n : String):
	for i in tree.size():
		if tree[i].name == n:
			return i
	return -1

func find_data(n : String):
	var idx = find(n)
	return tree[idx]

func setup():
	for t in tree:
		t.spell = G.spells.find_data(t.spell_name)
		assert(t.spell)
	update_spent_points()

func update_spent_points():
	spent_points.clear()
	for t in tree:
		var row = t.row
		if spent_points.size() < row + 1:
			spent_points.resize(row + 1)
		spent_points[row] += t.lv
