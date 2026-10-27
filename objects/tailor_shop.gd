extends Building

class_name TailorShop

func enable():
	super()
	
	G.enable_warehouse()
	
	var i = Item.new()
	i.setup("Flag")
	products.append(i)
	
	add_producing(0)
