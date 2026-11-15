extends Control

@export var item_ui : UiItem
@export var progress_bar : ProgressBar
@export var cancel_button : Button

var building : Building
var idx : int

func update_progress():
	var t = building.tasks[idx]
	if t.duration > 0:
		progress_bar.value = t.progress * 100.0 / t.duration
	else:
		progress_bar.value = (t.duration + t.progress) * 100.0 / t.duration

func setup(_building : Building, _idx : int):
	building = _building
	idx = _idx
	
	var t = building.tasks[idx]
	var p = building.products[t.id]
	item_ui.setup(G.get_res_data(p.type_name, p.id))

func _ready() -> void:
	cancel_button.pressed.connect(func():
		building.remove_task(idx)
	)
