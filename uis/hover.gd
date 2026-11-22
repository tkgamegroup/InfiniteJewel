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
	txt.text = text.trim_prefix("\n")
	
	var matched_text = ""
	for i in G.patterns.size():
		var p = G.patterns[i]
		if !p.match_with(coord).is_empty():
			matched_text += "\npattern %d is matched" % (i + 1)
	G.debug_ui.matched_text.text = matched_text.trim_prefix("\n")
