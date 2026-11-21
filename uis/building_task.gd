extends Control

@export var icon : UiIcon
@export var progress_bar : ProgressBar
@export var text : Label
@export var cancel_button : Button

var building : Building
var idx : int

func update_progress():
	var t = building.tasks[idx]
	if t.duration > 0:
		progress_bar.value = t.progress * 100.0 / t.duration
		var p = building.products[t.id]
		if p.type_name == &"Item" && G.warehouse_available_slot(p.id) == -1:
			text.text = "Warehouse is full"
		else:
			text.text = G.format_time(t.duration - t.progress)
	else:
		progress_bar.value = (t.duration + t.progress) * 100.0 / t.duration

func setup(_building : Building, _idx : int):
	building = _building
	idx = _idx
	
	var t = building.tasks[idx]
	var p = building.products[t.id]
	icon.setup(G.get_res_data(p.type_name, p.id))

func _ready() -> void:
	cancel_button.pressed.connect(func():
		building.remove_task(idx)
	)
