extends Control

class_name UiHover

@export var txt : Label

func update_hover(coord : Vector2i):
	if G.is_valid_coord(coord):
		var g = G.cells[coord].gem
		if g:
			var text = "Gem of %s" % str(G.Colors.find_key(g.color))
			text += "\nDurability: %d/%d" % [g.durability, g.max_durability]
			text += "\nValue: %d" % g.value
			text += "\n%d, %d" % [coord.x, coord.y]
			txt.text = text
			return
	txt.text = ""
