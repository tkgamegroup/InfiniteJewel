extends Control

class_name UiHover

@export var txt : Label

func update_hover(coord : Vector2i):
	var text = ""
	if G.is_valid_coord(coord):
		var cell = G.cells[coord]
		var g = cell.gem
		if g:
			text += "Gem of %s" % str(G.Colors.find_key(g.color))
			text += "\nDurability: %d/%d" % [g.durability, g.get_attr(&"max_durability")]
			text += "\nValue: %d" % g.get_attr(&"value")
		var i = cell.item
		if i:
			text += "Item: %s\n" % i.name
			text += i.get_description(-1)
		if !g && !i:
			if G.caves.has(coord):
				if G.caves_locked:
					text += "Unknown"
				else:
					text += "Cave"
		var cc = G.offset_to_cube(coord)
		text += "\n%d, %d (%d, %d, %d)" % [coord.x, coord.y, cc.x, cc.y, cc.z]
	txt.text = text
