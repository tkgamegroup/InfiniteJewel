extends Control

class_name UiBoard

@export var scroller : ScrollContainer
@export var tilemap : TileMapLayer
@export var content : Control

func get_page_pct():
	var vbar = scroller.get_v_scroll_bar()
	var from = vbar.value / vbar.max_value
	var to = (vbar.value + vbar.page) / vbar.max_value
	return Vector2(from, to)

func update_control():
	var used = tilemap.get_used_rect()
	tilemap.position.y = 8 - tilemap.map_to_local(used.position).y
	content.custom_minimum_size = tilemap.map_to_local(used.size)

func _ready() -> void:
	scroller.get_v_scroll_bar().value_changed.connect(func(v):
		var bar = scroller.get_v_scroll_bar()
		var aligned = floor(v / 16.0) * 16.0
		if !is_equal_approx(v, aligned):
			bar.value = aligned
	)
