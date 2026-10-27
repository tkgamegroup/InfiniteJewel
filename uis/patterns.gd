extends Control

class_name UiPatterns

@export var list : Control
@export var shop_button : Button
@export var shop : Control
@export var shop_list : Control
@export var shop_refresh_button : Button

const pattern_pb = preload("res://uis/pattern.tscn")

var on_sells : Array[Array] # 0 - ID, 1 - Pattern, 2 - Price

func on_add_pattern(p : Pattern):
	var ui = pattern_pb.instantiate()
	ui.setup(p)
	list.add_child(ui)

func random_pattern():
	var p = Pattern.new()
	var cs = [Vector2i(0, 0)]
	for i in 3:
		var cands = []
		for c in cs:
			for cc in G.offset_adjacents(c):
				if !cs.has(cc) && !cands.has(cc):
					if cc.x >= 0 && cc.x < 4 && cc.y >= 0 && cc.y < 4:
						cands.append(cc)
		cs.append(cands[randi_range(0, cands.size() - 1)])
	for c in cs:
		p.coords.append(G.offset_to_cube(c))
	return p

func refresh_prices():
	var price = get_pattern_price()
	for ui in shop_list.get_children():
		var btn = ui.get_child(1) as Button
		btn.text = "Buy %dG" % price

func buy(id : int):
	for i in on_sells.size():
		var item = on_sells[i]
		if item[0] == id && G.money >= item[2]:
			G.set_money(G.money - item[2])
			G.add_pattern(item[1])
			var ui = shop_list.get_child(i)
			ui.queue_free()
			on_sells.remove_at(i)
			refresh_prices()
			return

func get_pattern_price():
	var ret = 32
	if G.patterns.size() >= 4:
		var n = G.patterns.size() - 3
		ret *= (1 << n)
	return ret

static var next_item_id = 1
func refresh_shop():
	on_sells.clear()
	for n in shop_list.get_children():
		n.queue_free()
	var price = get_pattern_price()
	for i in 3:
		var p = random_pattern()
		var item_id = next_item_id
		on_sells.append([item_id, p, price])
		next_item_id += 1
		var ctrl = VBoxContainer.new()
		var ui = pattern_pb.instantiate()
		ui.setup(p)
		var btn = Button.new()
		btn.text = "Buy %dG" % price
		btn.pressed.connect(func():
			buy(item_id)
		)
		ctrl.add_child(ui)
		ctrl.add_child(btn)
		shop_list.add_child(ctrl)

func _ready() -> void:
	shop_button.pressed.connect(func():
		shop.visible = !shop.visible
		shop_button.text = "Shop"
		shop_button.text += "<<" if shop.visible else ">>"
		
	)
	shop_refresh_button.pressed.connect(func():
		refresh_shop()
	)
	refresh_shop()
