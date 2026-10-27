extends Control

class_name UiWarehouse

@export var list : Control

const item_pb = preload("res://uis/item.tscn")

func update():
	for n in list.get_children():
		n.queue_free()
	for i in G.warehouse_items.size():
		var arr = G.warehouse_items[i]
		var ui = item_pb.instantiate()
		ui.button.pressed.connect(func():
			var coord = G.random_place_from_top()
			if coord.x != -1 && coord.y != -1:
				G.place_item(i, coord)
		)
		ui.number.show()
		ui.number.text = "%d" % arr.size()
		list.add_child(ui)

func _ready() -> void:
	pass
