extends Building

class_name Factory

func enable():
	super()
	
	G.enable_warehouse()
	
	var i = Item.new()
	i.setup("Bomb")
	products.append(i)
	
	add_producing(0)
