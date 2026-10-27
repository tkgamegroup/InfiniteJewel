extends Control

@export var tilemap : TileMapLayer

var coords : Array[Vector3i]

func setup(p : Pattern):
	coords = p.coords.duplicate(true)
	var y_min = 4
	var y_max = 0
	for c in coords:
		y_min = min(y_min, c.y)
		y_max = min(y_max, c.y)
	if y_min < 0:
		for i in coords.size():
			coords[i].y += -y_min
			coords[i].z += y_min

func _ready() -> void:
	for c in coords:
		var cc = G.cube_to_offset(c)
		tilemap.set_cell(cc, 1, Vector2i(0, 0))
