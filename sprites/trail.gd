extends Node2D

@export var line : Line2D

func _process(_delta: float) -> void:
	line.add_point(position)
	if line.get_point_count() > 20:
		line.remove_point(0)
