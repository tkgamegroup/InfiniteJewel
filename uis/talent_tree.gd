extends Control

class_name UiTalentTree

@export var container : GridContainer
@export var dependencies_layer : Control
@export var timer : Timer

const slot_size = Vector2(42, 69)
const max_columns = 5
const hgap = 48.0
const vgap = 24.0

func slot_center(row : int, column : int):
	return Vector2(column, row) * (slot_size + Vector2(hgap, vgap)) + slot_size * Vector2(0.5, 0.3)

func _ready() -> void:
	container.columns = max_columns
	container.add_theme_constant_override(&"h_separation", hgap)
	container.add_theme_constant_override(&"v_separation", vgap)
	
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
		var ui = G.talent_pb.instantiate()
		ui.setup(t)
		container.get_child(row * max_columns + col).add_child(ui)
		t.ui = ui
		
	for t in G.talent_tree.tree:
		if !t.dependency.is_empty():
			var dep = G.talent_tree.find_data(t.dependency)
			var p0 = slot_center(dep.row, dep.column)
			var p1 = slot_center(t.row, t.column)
			var cutoff = slot_size.y * 0.5 / p0.distance_to(p1)
			var pdst = lerp(p0, p1, 1.0 - cutoff)
			p0 = lerp(p0, p1, cutoff)
			var line = Line2D.new()
			line.width = 2.0
			line.add_point(p0)
			line.add_point(pdst)
			dependencies_layer.add_child(line)
			var d = (pdst - p0).normalized()
			var rad = deg_to_rad(45.0)
			var arrow = Line2D.new()
			arrow.width = 2.0
			arrow.add_point(pdst + -d.rotated(rad) * 5.0)
			arrow.add_point(pdst)
			arrow.add_point(pdst + -d.rotated(-rad) * 5.0)
			dependencies_layer.add_child(arrow)
	
	timer.timeout.connect(func():
		for t in G.talent_tree.tree:
			t.ui.update_frame()
	)
