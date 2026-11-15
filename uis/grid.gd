extends GridContainer

func _draw() -> void:
	var count = get_child_count()
	if count == 0:
		return
	
	var size = get_child(0).size
	var hgap = get_theme_constant(&"h_separation")
	var vgap = get_theme_constant(&"v_separation")
	size += Vector2(hgap, vgap)
	var rows = ceili(float(count) / columns)
	var num = rows * columns
	for i in num:
		var col = i % columns
		var row = i / columns
		draw_rect(Rect2(size * Vector2(col, row), size), Color(1.0, 1.0, 1.0, 0.5), false, 1.0)
