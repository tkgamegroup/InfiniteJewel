extends FoldableContainer

class_name UiBuilding

@export var product_list : Control
@export var task_list : Control
@export var timer : Timer

const slot_size = Vector2(36.0, 36.0)
const task_pb = preload("uid://cskvv7238ctk5")

var building : Building

func update_title():
	title = "%s LV.%d" % [building.name, building.lv]

func update_product_list():
	for n in product_list.get_children():
		n.queue_free()
	for i in building.products.size():
		var p = building.products[i]
		var slot = Control.new()
		slot.custom_minimum_size = slot_size
		product_list.add_child(slot)
		if p:
			var ui = G.item_pb.instantiate()
			ui.setup(G.get_res_data(p.type_name, p.id))
			ui.set_pressed(func():
				building.add_task(i)
			)
			ui.extra_tooltip_cb = func():
				var text = "\n------\nDuration: %ds\n" % (p.duration / 10)
				match p.type_name:
					&"Item":
						text += "Click to produce."
					&"Tech": 
						text += "Click to research."
					&"Spell": 
						text += "Click to cast."
				return text
			slot.add_child(ui)

func update_task_list():
	for n in task_list.get_children():
		n.queue_free()
	for i in building.tasks.size():
		var ui = task_pb.instantiate()
		ui.setup(building, i)
		task_list.add_child(ui)

func _ready() -> void:
	update_title()
	timer.timeout.connect(func():
		for n in task_list.get_children():
			n.update_progress()
	)
