extends Control

func _draw():
	var tilemap = G.board_ui.tilemap
	var p0 = tilemap.map_to_local(Vector2i(0, G.watch_start.y))
	p0 -= Vector2(8.0, 8.0)
	var p1 = tilemap.map_to_local(Vector2i(G.board_width + 1, G.watch_end.y))
	p1 -= Vector2(0.0, 8.0)
	var rect = Rect2(p0, p1 - p0)
	draw_rect(rect, Color(1.0, 1.0, 0.0, 0.4))
	
	var dragger = G.board_ui.watch_dragger
	dragger.position = Vector2(p1.x - 16.0, (p0.y + p1.y - 16.0) * 0.5)
