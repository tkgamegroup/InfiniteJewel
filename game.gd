extends Node

enum Colors
{
	None,
	Red,
	Yellow,
	Green,
	Blue,
	Purple
}

const board_width : int = 64
var board_upper : int = 0
var board_lower : int = 1000
const area_size : int = 1000
const area_unlock_clear_size : int = 32
var cells : Dictionary[Vector2i, Cell]
var caves : Dictionary[Vector2i, int]
var caves_locked : bool = true
var patterns : Array[Pattern]
var watch_size : int = 4
var money : int = 0
var spells : Spells
var talent_tree : TalentTree
var technologies : Technologies
var item_datas : ItemDatas
var building_datas : BuildingDatas
var warehouse_enable : bool = false
## Array of Items
var warehouse_items : Array[Array]
var workshop : Building = Building.new()
var tailor_shop : Building = Building.new()
var watchtower : Building = Building.new()
var alchemy_workshop : Building = Building.new()
var buildings : Array[Building] = [workshop, tailor_shop, watchtower]

var selecting_item : int = -1

var stats : StatBlock = StatBlock.new()

var watch_offset : int = 0
var watch_start : Vector2i
var watch_end : Vector2i
## upper, lower
var area_unlock_clear_region : Array[int]
var area_unlock_clear_required_percentage : int = 10
var area_unlock_clear_required_number : int
var area_unlock_cleared_number : int
var holes : Dictionary[Vector2i, int]
var dead_cells : Dictionary[Vector2i, int]
var board_items : Array[Item]

@onready var canvas : CanvasLayer = $/root/Main/CanvasLayer
@onready var vfx : UiVisualEffects = $/root/Main/%VFX
@onready var board_ui : UiBoard = $/root/Main/%Board
@onready var block_ui : Control = $/root/Main/%Block
@onready var block_txt : Label = $/root/Main/%Block/PanelContainer/Label
@onready var money_txt : Label = $/root/Main/%Money
@onready var patterns_ui : UiPatterns = $/root/Main/%Patterns
@onready var warehouse_ui : UiWarehouse = $/root/Main/%Warehouse
@onready var workshop_ui : UiBuilding = $/root/Main/%Workshop
@onready var tailor_shop_ui : UiBuilding = $/root/Main/%TailorShop
@onready var watchtower_ui : UiBuilding = $/root/Main/%Watchtower
@onready var talent_tree_ui : UiTalentTree = $/root/Main/%TalentTree
@onready var debug_ui : UiDebug = $/root/Main/%Debug
@onready var hover_ui : UiHover = $/root/Main/%Hover
@onready var messages_ui : Control = $/root/Main/%Messages
@onready var step_timer : Timer = $/root/Main/StepTimer
@onready var refresh_timer : Timer = $/root/Main/RefreshTimer
@onready var board_size_timer : Timer = $/root/Main/BoardSizeTimer
@onready var hover_timer : Timer = $/root/Main/HoverTimer

# the bigger ui goes first so that preload has no problem with the dependencies
const spell_frames = preload("uid://dapneh85xjoae")
const pattern_pb = preload("uid://ct8pyfaf240h8")
const talent_pb = preload("uid://bprmmmbm1hmdk")
const task_pb = preload("uid://cskvv7238ctk5")
const icon_pb = preload("uid://ddno2ameayof3")
const message_pb = preload("uid://lvedrc62tume")

func cube_to_offset(c : Vector3i) -> Vector2i:
	var col = c.x
	var row = c.y + (c.x - (c.x & 1)) / 2
	return Vector2i(col, row)

func offset_to_cube(hex : Vector2i) -> Vector3i:
	var q = hex.x
	var r = hex.y - (hex.x - (hex.x & 1)) / 2
	return Vector3i(q, r, -q-r)

func cube_distance(a : Vector3i, b : Vector3i):
	return (abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)) / 2

func offset_distance(a : Vector2i, b : Vector2i):
	return cube_distance(offset_to_cube(a), offset_to_cube(b))

static var cube_dirs = [Vector3i(1, 0, -1), Vector3i(1, -1, 0), Vector3i(0, -1, 1), Vector3i(-1, 0, 1), Vector3i(-1, 1, 0), Vector3i(0, 1, -1)]

func cube_dir(d : int):
	return cube_dirs[d]

func cube_adjacents(c : Vector3i) -> Array[Vector3i]:
	var ret : Array[Vector3i] = []
	for d in cube_dirs:
		ret.append(c + d)
	return ret

func offset_adjacents(c : Vector2i) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	for cc in cube_adjacents(offset_to_cube(c)):
		var oc = cube_to_offset(cc)
		ret.append(oc)
	return ret

func cube_ring(c : Vector3i, r : int) -> Array[Vector3i]:
	var ret : Array[Vector3i] = []
	var cc = c + cube_dir(4) * r
	for i in 6:
		for j in r:
			ret.append(cc)
			cc = cc + cube_dir(i)
	return ret

func offset_ring(c : Vector2i, r : int) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	if r == 0:
		ret.append(c)
		return ret
	for cc in cube_ring(offset_to_cube(c), r):
		ret.append(cube_to_offset(cc))
	return ret

func cube_within(c : Vector3i, r : int) -> Array[Vector3i]:
	var ret : Array[Vector3i] = []
	for i in r + 1:
		for cc in cube_ring(c, i):
			ret.append(cc)
	return ret

func offset_within(c : Vector2i, r : int) -> Array[Vector2i]:
	var ret : Array[Vector2i] = []
	for i in r + 1:
		for cc in offset_ring(c, i):
			ret.append(cc)
	return ret

func is_valid_coord(c : Vector2i):
	return c.x >= 0 && c.x < board_width && c.y >= board_upper && c.y < board_lower

func add_new_cell(c : Vector2i):
	var cell = Cell.new()
	cells[c] = cell
	var is_cave = false
	if randi() % 100 < 3:
		is_cave = true
		for cc in offset_adjacents(c):
			if caves.has(cc):
				is_cave = false
				break
	var color = 0
	if !is_cave:
		var g = Gem.new()
		color = Colors.Red + randi() % 5
		g.setup(color, 1 + c.y, 1 + int(c.y / 256))
		cell.gem = g
	else:
		caves[c] = 1
	refresh_cell(c)

func get_board_page_range():
	var pct = board_ui.get_page_pct()
	var from_y = max(int(lerp(board_upper, board_lower, pct[0])) - 1, board_upper)
	var to_y = min(int(lerp(board_upper, board_lower, pct[1])), board_lower - 1)
	return [from_y, to_y]

func get_board_page_random_coord():
	var page_range = get_board_page_range()
	page_range[1] -= 10
	var cands = []
	for y in range(page_range[0], page_range[1]):
		for x in G.board_width:
			var c = Vector2i(x, y)
			if cells[c].gem:
				cands.append(Vector2i(x, y))
	return cands.pick_random()

func get_res_id(type_name : StringName, name : String):
	match type_name:
		&"Item": return item_datas.find(name)
		&"Spell": return spells.find(name)
		&"Talent": return talent_tree.find(name)
		&"Tech": return technologies.find(name)
	return -1

func get_res_data(type_name : StringName, id : int):
	match type_name:
		&"Item": return item_datas.datas[id].dummy
		&"Spell": return spells.datas[id]
		&"Talent": return talent_tree.tree[id]
		&"Tech": return technologies.datas[id]
	return null

func format_time(ticks : int):
	var secs = ticks / 10
	return "%02d:%02d" % [secs / 60, secs % 60]

func format_description(desc : String, obj, lv : int = 0):
	var ret = ""
	var placeholder = ""
	for c in desc:
		if c == "%":
			placeholder += "%"
			if placeholder.length() > 1 && placeholder.right(1) == "%":
				if placeholder.length() == 2:
					ret += "%"
				else:
					var name = placeholder.substr(1, placeholder.length() - 2)
					if name.begins_with("m:"):
						var idx = int(name.substr(2))
						var m = obj.modifiers[idx]
						ret += str(m.base_value + m.value_per_lv * lv)
					else:
						ret += str(obj.get_attr(name))
				placeholder = ""
		else:
			if placeholder.is_empty():
				ret += c
			else:
				placeholder += c
	return ret

func get_ui_pos(obj):
	match obj.type_name:
		&"Building":
			return obj.ui.get_global_rect().get_center()
	return Vector2(0.0, 0.0)

func set_money(v : int):
	money = v
	money_txt.text = "%d" % money

func add_pattern(p : Pattern):
	patterns.append(p)
	patterns_ui.on_add_pattern(p)

func enable_warehouse():
	if warehouse_enable:
		return
	warehouse_enable = true
	warehouse_ui.show()

func get_position(coords : Array, is_global : bool = false) -> Vector2:
	var ret = Vector2(0, 0)
	for c in coords:
		ret += board_ui.tilemap.map_to_local(c)
	if coords.size() > 1:
		ret /= coords.size()
	if is_global:
		ret += board_ui.tilemap.global_position
	else:
		ret += board_ui.tilemap.position
	return ret

func block_controls(text : String):
	block_ui.show()
	block_txt.text = text

func unblock_controls():
	block_ui.hide()
	block_txt.text = ""

func add_damage_number(coord : Vector2i, value : int, is_crit : bool):
	var pos = get_position([coord])
	var y_range = board_ui.get_page_pct() * board_ui.content.size.y
	if pos.y + 100.0 < y_range[0] || pos.y - 100.0 > y_range[1]:
		return
	var txt = Label.new()
	txt.text = ("%d" % value) + ("!" if is_crit else "")
	txt.position = pos
	txt.reset_size()
	txt.position -= txt.size * 0.5
	board_ui.content.add_child(txt)
	var tween = create_tween()
	tween.tween_property(txt, "modulate:a", 0.0, 0.15).set_delay(0.2)
	tween.tween_callback(txt.queue_free)

func add_combo_text(coords : Array):
	var pos = get_position(coords)
	var txt = Label.new()
	txt.text = "Combo"
	txt.reset_size()
	pos -= txt.size * 0.5
	txt.position = pos
	board_ui.content.add_child(txt)
	var tween = create_tween()
	tween.tween_property(txt, "position", pos - Vector2(0.0, 40.0), 0.2)
	tween.parallel().tween_property(txt, "modulate:a", 0.0, 0.15).set_delay(0.2)
	tween.tween_callback(txt.queue_free)

func add_message(text : String):
	var lb = message_pb.instantiate()
	lb.text = text
	messages_ui.add_child(lb)
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(lb, "modulate:a", 0.0, 1.5)
	tween.tween_callback(lb.queue_free)

func take_damage(c : Vector2i, value : int, is_crit : bool):
	var g = cells[c].gem
	if g:
		if is_crit:
			value *= 2
		g.durability -= value
		add_damage_number(c, value, is_crit)
		if g.durability <= 0:
			destroy_cell(c)

func destroy_cell(c : Vector2i):
	if dead_cells.has(c):
		return
	var g = cells[c].gem
	if !g:
		return
	var value = g.get_attr(&"value")
	var sp = ColorRect.new()
	sp.color = Color.GOLD
	sp.size = Vector2(5, 5)
	sp.position = board_ui.tilemap.to_global(board_ui.tilemap.map_to_local(c))
	canvas.add_child(sp)
	var tween = create_tween()
	var target_rect = money_txt.get_global_rect()
	tween.tween_property(sp, "position", target_rect.position + Vector2(0, target_rect.size.y * 0.5), 0.5)
	tween.tween_callback(func():
		set_money(money + value)
	)
	tween.tween_callback(sp.queue_free)
	dead_cells[c] = 1

func warehouse_find_item(res_id : int):
	for i in warehouse_items.size():
		var arr = warehouse_items[i]
		if arr[0].res_id == res_id:
			return i
	return -1

func warehouse_available_slot(res_id : int):
	var idx = warehouse_find_item(res_id)
	if idx == -1:
		return warehouse_items.size()
	var arr = warehouse_items[idx]
	if arr.size() < arr[0].get_data().max_stack:
		return idx
	return -1

func warehouse_add_item(i : Item, slot : int = -1):
	if slot == -1:
		slot = warehouse_available_slot(i.res_id)
	if slot == -1:
		return
	if slot == warehouse_items.size():
		slot = warehouse_items.bsearch_custom([i], func(a, b):
			return a[0].res_id < b[0].res_id
		)
		warehouse_items.insert(slot, [i])
		warehouse_ui.insert(slot)
	else:
		warehouse_items[slot].append(i)
		warehouse_ui.flash(slot)

func warehouse_get_item(slot : int):
	var is_empty = false
	var arr = warehouse_items[slot]
	var i = arr.pop_back() as Item
	if arr.is_empty():
		warehouse_items.remove_at(slot)
		is_empty = true
	if is_empty:
		warehouse_ui.remove(slot)
	else:
		warehouse_ui.flash(slot)
	return [i, is_empty]

func place_item(warehouse_slot : int, c : Vector2i):
	if warehouse_items.size() <= warehouse_slot:
		return -1
	var ret = warehouse_get_item(warehouse_slot)
	var i = ret[0]
	var cell = cells[c]
	if cell.is_empty():
		cell.item = i
		i.coord = c
		i.on_placed()
		if i.is_aura():
			aura_entered(i)
		board_items.append(i)
	return ret[1]

func random_place_from_top():
	var cands = []
	for x in G.board_width:
		var c = Vector2i(x, G.board_upper)
		if G.cells[c].is_empty():
			cands.append(x)
	if !cands.is_empty():
		var x = cands[randi_range(0, cands.size() - 1)]
		var c = Vector2i(x, 1)
		while true:
			if !G.cells[c].is_empty():
				c.y = c.y - 1
				break
			c.y = c.y + 1
		return c
	return Vector2i(-1, -1)

func aura_entered(i : Item):
	var targets = []
	for c in offset_within(i.coord, i.get_attr(&"range")):
		if is_valid_coord(c):
			var cell = cells[c]
			cell.auras.append(i.coord)
			if cell.gem:
				targets.append(cell.gem)
			if cell.item:
				targets.append(cell.item)
	for s in i.spells:
		if s.is_aura:
			s.apply(i, targets, 0)

func aura_left(i : Item):
	var targets = []
	for c in offset_within(i.coord, i.get_attr(&"range")):
		if is_valid_coord(c):
			var cell = cells[c]
			cell.auras.erase(i.coord)
			if cell.gem:
				targets.append(cell.gem)
			if cell.item:
				targets.append(cell.item)
	for s in i.spells:
		if s.is_aura:
			s.revert(i, targets)

var damage_ticks : int = 0

func step():
	var watch_page = board_ui.get_page_pct()
	watch_start = Vector2i(0, watch_offset + max(int(round(lerp(board_upper, board_lower, watch_page[0]))), board_upper))
	watch_end = Vector2i(G.board_width, watch_start.y + watch_size)
	board_ui.content.queue_redraw()
	
	if damage_ticks >= 10:
		for y in range(watch_start.y, watch_end.y):
			for x in board_width:
				var off = Vector2i(x, y)
				for p in patterns:
					var res = p.match_with(off)
					if !res.is_empty():
						for c in res:
							var damage = p.get_attr(&"damage") * 1
							var crit = randf() < p.get_attr(&"crit_chance") * 0.01
							take_damage(c, damage, crit)
		damage_ticks = 0
	damage_ticks += 1
	
	for b in buildings:
		b.step()
	
	for i in board_items:
		i.step()
	
	for c in dead_cells.keys():
		if !caves.has(c):
			holes[c] = 1
		var cell = cells[c]
		cell.gem = null
		if cell.item:
			board_items.erase(cell.item)
			if cell.item.is_aura():
				aura_left(cell.item)
		cell.item = null
		if c.y >= area_unlock_clear_region[0] && c.y < area_unlock_clear_region[1]:
			area_unlock_cleared_number += 1
	dead_cells.clear()
	
	var new_holes : Dictionary[Vector2i, int] = {}
	var new_poses : Dictionary[Vector2i, Vector2i] = {}
	var current_holes = holes.keys()
	current_holes.sort_custom(func(a: Vector2i, b: Vector2i): return a.y < b.y)
	for c in current_holes:
		var c_up = Vector2i(c.x, c.y - 1)
		if caves.has(c_up):
			c_up.y -= 1
		if is_valid_coord(c_up):
			var cell_up = cells[c_up]
			var cell = cells[c]
			if !cell_up.is_empty():
				var g = cell_up.gem
				var i = cell_up.item
				if !cell_up.auras.is_empty() && (g || i):
					for ac in cell_up.auras:
						var a = cells[ac].item
						for s in a.spells:
							if s.is_aura:
								if g:
									s.revert(a, [g])
								if i:
									s.revert(a, [i])
				if i && i.is_aura():
					aura_left(i)
				cell_up.gem = null
				cell_up.item = null
				cell.gem = g
				cell.item = i
				if i:
					i.coord = c
				if !cell.auras.is_empty() && (g || i):
					for ac in cell_up.auras:
						var a = cells[ac].item
						for s in i.spells:
							if s.is_aura:
								if g:
									s.apply(a, [g], 0)
								if i:
									s.apply(a, [i], 0)
				if i && i.is_aura():
					aura_entered(i)
				new_holes[c_up] = 1
				for x in range(-3, 4):
					for y in range(-3, 4):
						new_poses[c + Vector2i(x, y)] = c
	holes = new_holes
	
	for off in new_poses.keys():
		for p in patterns:
			var res = p.match_with(off)
			if res.has(new_poses[off]):
				for c in res:
					add_combo_text(res)
					destroy_cell(c)

func refresh_cell(c : Vector2i):
	var img_id = -1
	var cell = cells[c]
	if !cell.is_empty():
		var g = cell.gem
		var i = cell.item
		if g:
			img_id = g.color
		else:
			img_id = i.get_data().image_id
			if caves.has(c):
				img_id += 1
	else:
		if caves.has(c):
			if caves_locked:
				img_id = 6
			else:
				img_id = 7
	board_ui.tilemap.set_cell(c, img_id, Vector2i(0, 0))

func refresh_board():
	var page_range = get_board_page_range()
	for y in range(page_range[0], page_range[1]):
		for x in board_width:
			var c = Vector2i(x, y)
			refresh_cell(c)

func board_size_changed():
	area_unlock_clear_region = [board_lower - area_unlock_clear_size, board_lower]
	area_unlock_clear_required_number = int(area_unlock_clear_size * board_width * area_unlock_clear_required_percentage * 0.01)
	board_ui.update_control()

func update_board_size():
	var prev_board_upper = board_upper
	var prev_board_lower = board_lower
	while true:
		var changed = false
		var all_empty = true
		for x in board_width:
			var c = Vector2i(x, board_upper)
			if cells[c].gem != null:
				all_empty = false
				break
		if all_empty:
			for x in board_width:
				var c = Vector2i(x, board_upper)
				cells.erase(c)
				board_ui.tilemap.set_cell(c, -1, Vector2i(0, 0))
			board_upper += 1
			changed = true
		if !changed:
			break
	if area_unlock_cleared_number >= area_unlock_clear_required_number:
		var y0 = board_lower
		board_lower += area_size
		for y in range(y0, board_lower):
			for x in board_width:
				add_new_cell(Vector2i(x, y))
		area_unlock_cleared_number = 0
	if board_upper != prev_board_upper || board_lower != prev_board_lower:
		board_size_changed()

func update_hover():
	var mouse_pos = board_ui.tilemap.get_local_mouse_position()
	var coord = board_ui.tilemap.local_to_map(mouse_pos)
	hover_ui.update_hover(coord)

func select_item(id : int):
	selecting_item = id
	block_controls("Cancel")
	var item_data = item_datas.datas[id]
	var tex = board_ui.get_tile_texture(item_data.image_id)
	Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, Vector2(8.0, 8.0))

func cancel_selct_item():
	selecting_item = -1
	Input.set_custom_mouse_cursor(null)
	unblock_controls()

func _ready() -> void:
	spells = load("uid://drfsf7frpauo8")
	talent_tree = load("uid://cuec3l8g0e5k6")
	talent_tree.setup()
	item_datas = load("uid://b1xiow740xxr2")
	item_datas.setup()
	technologies = load("uid://bgwgytx16cvsx")
	technologies.setup()
	building_datas = load("uid://b2d7rxm5u6rna")
	building_datas.setup()
	
	stats.init_attributes({&"caves_unlocked":0,&"workshop_enable":0,&"tailor_shop_enable":0,&"watchtower_enable":0})
	stats.attributes[&"caves_unlocked"].callbacks.append(func(v : int):
		if v == 1:
			if caves_locked:
				caves_locked = false
	)
	stats.attributes[&"workshop_enable"].callbacks.append(func(v : int):
		if v == 1:
			workshop.enable()
	)
	stats.attributes[&"tailor_shop_enable"].callbacks.append(func(v : int):
		if v == 1:
			tailor_shop.enable()
	)
	stats.attributes[&"watchtower_enable"].callbacks.append(func(v : int):
		if v == 1:
			watchtower.enable()
	)
	
	var p1 = Pattern.new()
	p1.setup([Vector3i(0, 0, 0), Vector3i(1, 0, -1), Vector3i(2, 0, -2), Vector3i(3, 0, -3)] as Array[Vector3i])
	add_pattern(p1)
	var p2 = Pattern.new()
	p2.setup([Vector3i(0, 0, 0), Vector3i(0, 1, -1), Vector3i(0, 2, -2), Vector3i(0, 3, -3)] as Array[Vector3i])
	add_pattern(p2)
	var p3 = Pattern.new()
	p3.setup([Vector3i(0, 0, 0), Vector3i(1, -1, 0), Vector3i(2, -2, 0), Vector3i(3, -3, 0)] as Array[Vector3i])
	add_pattern(p3)
	
	for y in range(board_upper, board_lower):
		for x in board_width:
			add_new_cell(Vector2i(x, y))
	board_size_changed()
	
	block_ui.gui_input.connect(func(event: InputEvent):
		if selecting_item != -1:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
					cancel_selct_item()
	)
	
	board_ui.content.mouse_entered.connect(func():
		hover_timer.start()
	)
	board_ui.content.mouse_exited.connect(func():
		hover_timer.stop()
		hover_ui.txt.text = ""
	)
	board_ui.content.gui_input.connect(func(event: InputEvent):
		if selecting_item != -1:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
					if !caves_locked:
						var coord = board_ui.tilemap.local_to_map(event.position)
						var ok = false
						if caves.has(coord):
							if cells[coord].is_empty():
								ok = true
						else:
							var dist = 10000.0
							for c in offset_adjacents(coord):
								if caves.has(c):
									var d = board_ui.tilemap.map_to_local(c).distance_to(event.position)
									if d < dist:
										dist = d
										coord = c
										ok = true
						if ok:
							if place_item(warehouse_find_item(selecting_item), coord):
								cancel_selct_item()
		else:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
					var coord = board_ui.tilemap.local_to_map(event.position)
					if debug_ui.click_clear_enable:
						for c in offset_within(coord, debug_ui.click_clear_range):
							if is_valid_coord(c):
								destroy_cell(c)
					if debug_ui.click_spawn_enable:
						var cell = cells[coord]
						if cell.gem:
							cell.gem = null
						if cell.item:
							cell.item = null
						var i = Item.new()
						i.setup(debug_ui.click_spawn_id)
						cell.item = i
						i.coord = coord
						board_items.append(i)
	)
	
	workshop_ui.building = workshop
	workshop.ui = workshop_ui
	workshop.setup(building_datas.find("Workshop"))
	tailor_shop_ui.building = tailor_shop
	tailor_shop.ui = tailor_shop_ui
	tailor_shop.setup(building_datas.find("Tailor Shop"))
	watchtower_ui.building = watchtower
	watchtower.ui = watchtower_ui
	watchtower.setup(building_datas.find("Watchtower"))
	
	step_timer.timeout.connect(step)
	refresh_timer.timeout.connect(refresh_board)
	board_size_timer.timeout.connect(update_board_size)
	hover_timer.timeout.connect(update_hover)
