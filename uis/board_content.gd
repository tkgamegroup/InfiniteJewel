extends Control

func _draw():
	var tilemap = G.board_ui.tilemap
	var p0 = tilemap.map_to_local(Vector2i(G.board_width, G.watch_start.y))
	p0.y -= 8.0
	var p1 = tilemap.map_to_local(Vector2i(G.board_width, G.watch_end.y))
	p1.y -= 8.0
	draw_line(p0, p1, Color.WHITE, 8)
