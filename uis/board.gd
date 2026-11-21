extends Control

class_name UiBoard

@export var scroller : ScrollContainer
@export var tilemap : TileMapLayer
@export var content : Control
@export var watch_dragger : Control
@export var area_unlock_text : Label
var watch_dragging : bool = false
var watch_dragger_offset : float

func get_page_pct():
	var vbar = scroller.get_v_scroll_bar()
	var from = vbar.value / vbar.max_value
	var to = (vbar.value + vbar.page) / vbar.max_value
	return Vector2(from, to)

func update_control():
	var used = tilemap.get_used_rect()
	tilemap.position.y = 8 - tilemap.map_to_local(used.position).y
	content.custom_minimum_size = tilemap.map_to_local(used.size)

func get_tile_texture(id):
	return tilemap.tile_set.get_source(id).texture

func _ready() -> void:
	scroller.get_v_scroll_bar().value_changed.connect(func(v):
		var bar = scroller.get_v_scroll_bar()
		var aligned = floor(v / 16.0) * 16.0
		if !is_equal_approx(v, aligned):
			bar.value = aligned
	)
	scroller.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					scroller.scroll_vertical -= 16
					scroller.accept_event()
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					scroller.scroll_vertical += 16
					scroller.accept_event()
	)
	watch_dragger.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					watch_dragging = true
					watch_dragger_offset = content.get_local_mouse_position().y
				else:
					watch_dragging = false
		elif event is InputEventMouseMotion:
			if watch_dragging:
				var mpos = content.get_local_mouse_position()
				var change = int((mpos.y - watch_dragger_offset) / 16.0)
				var v = clamp(G.watch_offset + change, 0, 64 - G.watch_size)
				if G.watch_offset != v:
					G.watch_offset = v
					watch_dragger_offset = mpos.y
	)
