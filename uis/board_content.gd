extends Control

func draw_watch():
	var tilemap = G.board_ui.tilemap
	var p0 = tilemap.map_to_local(Vector2i(0, G.watch_start.y))
	p0 -= Vector2(8.0, 8.0)
	var p1 = tilemap.map_to_local(Vector2i(G.board_width + 1, G.watch_end.y))
	p1 -= Vector2(0.0, 8.0)
	var rect = Rect2(p0, p1 - p0)
	draw_rect(rect, Color(1.0, 1.0, 0.0, 0.4))
	
	var dragger = G.board_ui.watch_dragger
	dragger.position = Vector2(p1.x - 16.0, (p0.y + p1.y - 16.0) * 0.5)

func draw_unlock():
	var tilemap = G.board_ui.tilemap
	var p0 = tilemap.map_to_local(Vector2i(0, G.area_unlock_clear_region[0]))
	p0 -= Vector2(8.0, 8.0)
	var p1 = tilemap.map_to_local(Vector2i(G.board_width + 1, G.area_unlock_clear_region[1]))
	p1 -= Vector2(0.0, 8.0)
	var rect = Rect2(p0, p1 - p0)
	rect.size.x = G.board_ui.size.x
	draw_rect(rect, Color(0.5, 0.0, 1.0, 0.4))

	var unlock_text = G.board_ui.area_unlock_text
	unlock_text.position = Vector2(p1.x - 16.0, p0.y)
	unlock_text.size.x = G.board_ui.size.x - unlock_text.position.x
	unlock_text.size.y = p1.y - p0.y
	unlock_text.text = "Clear to unlock new area\n%d%% remaining" % max(0, int(100.0 - G.area_unlock_cleared_number * 100.0 / G.area_unlock_clear_required_number))

func _draw():
	draw_watch()
	draw_unlock()
