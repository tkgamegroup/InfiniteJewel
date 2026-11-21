extends StatBlock

class_name Building

const type_name : StringName = &"Building"

var name : String
var res_id : int
var is_enable : bool = false
var products : Array[Product]
var tasks : Array[BuildingTask]
var lv : int = 1

var ui : UiBuilding = null

func _init() -> void:
	init_attributes({&"production_time_decrease":0,&"research_time_decrease":0})

func get_data() -> BuildingData:
	if res_id == -1:
		return null
	return G.building_datas.datas[res_id]

func setup(id : int):
	assert(id != -1)
	res_id = id
	var d = get_data()
	name = d.name
	d.dummy.transfer_born_stats(self)

func enable():
	if is_enable:
		return
	is_enable = true
	
	G.enable_warehouse()
	collect_products()
	
	ui.show()
	ui.timer.start()

func add_product(p : Product, idx : int):
	if p.index == -1:
		var added = false
		for i in products.size():
			if products[i] == null:
				products[i] = p
				added = true
				break
		if !added:
			products.append(p)
	else:
		if p.index >= products.size():
			products.resize(p.index + 1)
		products[p.index] = p

func collect_products():
	products.clear()
	var d = get_data()
	for p in d.products:
		if p.building_lv <= lv:
			if p.type_name == &"Spell" && p.name == "upgrade" && p.building_lv < lv:
				continue
			if p.type_name == &"Tech" && G.technologies.datas[p.id].acquired:
				continue
			add_product(p, p.index)
	
	ui.update_product_list()

func get_duration(p : Product):
	var ret = p.duration
	match p.type_name:
		&"Item":
			var decrease = get_attr(&"production_time_decrease")
			if decrease > 0:
				ret *= (100 - decrease) * 0.01
		&"Tech":
			var decrease = get_attr(&"research_time_decrease")
			if decrease > 0:
				ret *= (100 - decrease) * 0.01
	return ret

func task_rewind(t : BuildingTask):
	var p = products[t.id]
	t.duration = get_duration(p)
	t.progress = 0

func add_task(idx : int):
	if products.size() <= idx:
		return
	if tasks.size() >= 1:
		return
	var p = products[idx]
	if p == null:
		return
	var t = BuildingTask.new()
	t.id = idx
	task_rewind(t)
	tasks.append(t)
	
	ui.update_task_list()

func remove_task(idx : int):
	if tasks.size() <= idx:
		return
	tasks.remove_at(idx)
	
	ui.update_task_list()

func step():
	if is_enable:
		for i in tasks.size():
			var t = tasks[i]
			var p = products[t.id]
			match p.type_name:
				&"Item":
					var slot = G.warehouse_available_slot(p.id)
					if slot != -1:
						if t.progress >= t.duration:
							var item = Item.new()
							item.setup(p.id)
							G.warehouse_add_item(item, slot)
							task_rewind(t)
						else:
							t.advance()
				&"Tech":
					if t.progress >= t.duration:
						var tech = G.technologies.datas[p.id]
						tech.acquire()
						collect_products()
						remove_task(i)
					else:
						t.advance()
				&"Spell":
					var spell = G.spells.datas[p.id]
					if t.channeling.spell:
						t.channeling.step(self, 1)
						t.progress += 1
						if !t.channeling.spell:
							task_rewind(t)
					else:
						if t.progress >= t.duration:
							if spell.name == "upgrade":
								lv += 1
								collect_products()
								remove_task(i)
								ui.update_title()
							else:
								if !spell.effects.is_empty():
									for e in spell.effects:
										e.excute(self)
									task_rewind(t)
								else:
									if spell.channel_duration != -1:
										t.channeling.start(self, spell)
										t.duration = -spell.channel_duration
										t.progress = 0
						else:
							t.advance()
