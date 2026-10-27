extends Control

class_name UiTalents

@export var container : GridContainer

const talent_pb = preload("res://uis/talent.tscn")
const slot_size = Vector2(42, 69)
const max_columns = 5

func _ready() -> void:
	container.columns = max_columns
	
	for t in G.talent_tree.tree:
		var row = t.row
		var curr_rows = container.get_child_count() / max_columns
		if row >= curr_rows:
			var n = row - curr_rows + 1
			for i in n:
				for j in max_columns:
					var slot = Control.new()
					slot.custom_minimum_size = slot_size
					container.add_child(slot)
		var col = t.column
		var talent_ui = talent_pb.instantiate()
		talent_ui.setup(t)
		container.get_child(row * max_columns + col).add_child(talent_ui)
	for row_ui in container.get_children():
		pass
