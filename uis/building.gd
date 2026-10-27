extends FoldableContainer

class_name UiBuilding

@export var product_name : Label
@export var product_progress : ProgressBar
@export var timer : Timer

var building : Building

func _ready() -> void:
	timer.timeout.connect(func():
		if building.producing.is_empty():
			product_name.text = "--"
			product_progress.value = 0.0
		else:
			product_name.text = building.producing[0]
			product_progress.value = building.producing[1] * 100.0 / building.producing[2]
	)
