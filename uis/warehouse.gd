extends Control

class_name UiWarehouse

@export var list : Control

func insert(idx : int):
	var arr = G.warehouse_items[idx]
	var res_id = arr[0].res_id
	var ui = G.icon_pb.instantiate()
	ui.setup(arr[0])
	ui.set_pressed(func():
		G.select_item(res_id)
	)
	ui.number.show()
	list.add_child(ui)
	list.move_child(ui, idx)
	flash(idx)

func remove(idx : int):
	list.get_child(idx).queue_free()

func flash(idx : int):
	var arr = G.warehouse_items[idx]
	var ui = list.get_child(idx)
	ui.number.text = "%d" % arr.size()
	ui.number.scale = Vector2(1.2, 1.2)
	var tween = G.create_tween()
	tween.tween_property(ui.number, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

func _ready() -> void:
	pass
