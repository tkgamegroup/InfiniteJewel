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
var cells : Dictionary[Vector2i, Cell]
var patterns : Array[Pattern]
var watch_size : int = 4
var money : int = 0
var talent_tree : TalentTree
var warehouse_enable : bool = false
var warehouse_max_slots : int = 16
## Array of Items
var warehouse_items : Array[Array]
var factory : Factory = Factory.new()
var tailor_shop : TailorShop = TailorShop.new()
var buildings : Array[Building] = [factory, tailor_shop]
var debug_click_clear_enable : bool = false
var debug_click_clear_range : int = 0
var debug_click_spawn_enable : bool = false
var debug_click_spawn_name : String = ""

var stats : StatBlock = StatBlock.new()

var watch_start : Vector2i
var watch_end : Vector2i
var holes : Dictionary[Vector2i, int]
var dead_cells : Dictionary[Vector2i, int]
var board_items : Array[Item]

@onready var canvas : CanvasLayer = $/root/Main/CanvasLayer
@onready var board_ui : UiBoard = $/root/Main/%Board
@onready var money_txt : Label = $/root/Main/CanvasLayer/HBoxContainer/VBoxContainer/Label
@onready var patterns_ui : UiPatterns = $/root/Main/%Patterns
@onready var warehouse_ui : UiWarehouse = $/root/Main/%Warehouse
@onready var factory_ui : UiBuilding = $/root/Main/%Factory
@onready var tailor_ui : UiBuilding = $/root/Main/%TailorShop
@onready var hover_ui : UiHover = $/root/Main/%Hover
@onready var step_timer : Timer = $/root/Main/StepTimer
@onready var refresh_timer : Timer = $/root/Main/RefreshTimer
@onready var board_size_timer : Timer = $/root/Main/BoardSizeTimer
@onready var debug_click_clear_check : CheckBox = $/root/Main/CanvasLayer/HBoxContainer/VBoxContainer/Debug/VBoxContainer/HBoxContainer/CheckBox
@onready var debug_click_clear_range_spin : SpinBox = $/root/Main/CanvasLayer/HBoxContainer/VBoxContainer/Debug/VBoxContainer/HBoxContainer/SpinBox
@onready var debug_click_spawn_check : CheckBox = $/root/Main/CanvasLayer/HBoxContainer/VBoxContainer/Debug/VBoxContainer/HBoxContainer2/CheckBox
@onready var debug_click_spawn_option : OptionButton = $/root/Main/CanvasLayer/HBoxContainer/VBoxContainer/Debug/VBoxContainer/HBoxContainer2/OptionButton
@onready var hover_timer : Timer = $/root/Main/HoverTimer

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

func update_attributes(obj):
	obj.reset_attributes()

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

func add_damage_number(coord : Vector2i, value : int):
	var pos = board_ui.tilemap.map_to_local(coord) + board_ui.tilemap.position
	var y_range = board_ui.get_page_pct() * board_ui.content.size.y
	if pos.y + 100.0 < y_range[0] || pos.y - 100.0 > y_range[1]:
		return
	var txt = Label.new()
	txt.text = "%d" % value
	txt.position = pos
	txt.reset_size()
	txt.position -= txt.size * 0.5
	board_ui.content.add_child(txt)
	var tween = create_tween()
	tween.tween_property(txt, "modulate:a", 0.0, 0.15).set_delay(0.2)
	tween.tween_callback(txt.queue_free)

func take_damage(c : Vector2i, value : int):
	var g = cells[c].gem
	if g:
		g.durability -= value
		add_damage_number(c, value)
		if g.durability <= 0:
			destroy_cell(c)

func destroy_cell(c : Vector2i):
	if dead_cells.has(c):
		return
	var g = cells[c].gem
	if !g:
		return
	var value = g.value
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

func warehouse_available_slot(n : String):
	for i in warehouse_items.size():
		var arr = warehouse_items[i]
		if arr[0].name == n && arr.size() < arr[0].max_stack:
			return i
	if warehouse_items.size() < warehouse_max_slots:
		return warehouse_items.size()
	return -1

func warehouse_add_item(i : Item, idx : int = -1):
	if idx == -1:
		idx = warehouse_available_slot(i.name)
	if idx == -1:
		return
	if idx == warehouse_items.size():
		warehouse_items.append([i])
		warehouse_items.sort_custom(func(a, b):
			return a[0].res_id < b[0].res_id
		)
	else:
		warehouse_items[idx].append(i)
	warehouse_ui.update()

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

func place_item(warehouse_slot : int, c : Vector2i):
	if warehouse_items.size() <= warehouse_slot:
		return
	var arr = warehouse_items[warehouse_slot]
	var i = arr.pop_back() as Item
	if arr.is_empty():
		warehouse_items.remove_at(warehouse_slot)
	warehouse_ui.update()
	var cell = cells[c]
	if cell.is_empty():
		cell.item = i
		i.coord = c
		board_items.append(i)

var damage_ticks : int = 0

func step():
	var watch_page = board_ui.get_page_pct()
	watch_start = Vector2i(0, max(int(round(lerp(board_upper, board_lower, watch_page[0]))), board_upper))
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
							take_damage(c, p.get_attr(&"Damage") * 1)
		damage_ticks = 0
	damage_ticks += 1
	
	for b in buildings:
		if b.is_enable:
			if !b.producing.is_empty():
				if b.producing[1] >= b.producing[2]:
					var slot = warehouse_available_slot(b.producing[0])
					if slot != -1:
						var i = Item.new()
						i.setup(b.producing[0])
						warehouse_add_item(i, slot)
						b.producing[1] = 0
				else:
					b.producing[1] += 1 * 10
	
	for i in board_items:
		if !i.on_event.is_null():
			i.on_event.call("tick")
	
	for c in dead_cells.keys():
		holes[c] = 1
		var cell = cells[c]
		cell.gem = null
		if cell.item:
			board_items.erase(cell.item)
		cell.item = null
	dead_cells.clear()
	
	var new_holes : Dictionary[Vector2i, int] = {}
	var current_holes = holes.keys()
	current_holes.sort_custom(func(a: Vector2i, b: Vector2i): return a.y < b.y)
	for c in current_holes:
		var c_up = Vector2i(c.x, c.y - 1)
		if is_valid_coord(c_up):
			var cell_up = cells[c_up]
			var cell = cells[c]
			if !cell_up.is_empty():
				var g = cell_up.gem
				var i = cell_up.item
				cell.gem = g
				cell.item = i
				cell_up.gem = null
				cell_up.item = null
				new_holes[c_up] = 1
				if i:
					i.coord = c
	holes = new_holes

func refresh_board():
	var pct = board_ui.get_page_pct()
	var from_y = max(int(lerp(board_upper, board_lower, pct[0])) - 1, board_upper)
	var to_y = min(int(lerp(board_upper, board_lower, pct[1])) + 1, board_lower - 1)
	for y in range(from_y, to_y):
		for x in board_width:
			var c = Vector2i(x, y)
			var cell = cells[c]
			if cell.is_empty():
				board_ui.tilemap.set_cell(c, -1)
			else:
				var g = cell.gem
				var i = cell.item
				if g:
					board_ui.tilemap.set_cell(c, g.color, Vector2i(0, 0))
				else:
					board_ui.tilemap.set_cell(c, i.image_id, Vector2i(0, 0))

func board_size_changed():
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
	if board_upper != prev_board_upper || board_lower != prev_board_lower:
		board_size_changed()

func update_hover():
	var mouse_pos = board_ui.tilemap.get_local_mouse_position()
	var coord = board_ui.tilemap.local_to_map(mouse_pos)
	hover_ui.update_hover(coord)

func _ready() -> void:
	talent_tree = load("uid://cuec3l8g0e5k6")
	
	stats.init_attributes({&"FactoryEnable":0,&"TailorShopEnable":0})
	stats.attributes[&"FactoryEnable"].callbacks.append(func(v : int):
		if v == 1:
			factory.enable()
	)
	stats.attributes[&"TailorShopEnable"].callbacks.append(func(v : int):
		if v == 1:
			tailor_shop.enable()
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
			var c = Vector2i(x, y)
			var g = Gem.new()
			g.color = Colors.Red + randi() % 5
			g.max_durability = 1 + y
			g.durability = g.max_durability
			g.value = 1 + int(y / 64)
			var cell = Cell.new()
			cell.gem = g
			cells[c] = cell
			board_ui.tilemap.set_cell(c, g.color, Vector2i(0, 0))
	board_size_changed()
	
	board_ui.content.mouse_entered.connect(func():
		hover_timer.start()
	)
	board_ui.content.mouse_exited.connect(func():
		hover_timer.stop()
		hover_ui.txt.text = ""
	)
	board_ui.content.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
				var coord = board_ui.tilemap.local_to_map(event.position)
				if debug_click_clear_enable:
					for c in offset_within(coord, debug_click_clear_range):
						if is_valid_coord(c):
							destroy_cell(c)
				if debug_click_spawn_enable:
					var cell = cells[coord]
					if cell.gem:
						cell.gem = null
					if cell.item:
						cell.item = null
					var i = Item.new()
					i.setup(debug_click_spawn_name)
					cell.item = i
					i.coord = coord
					board_items.append(i)
	)
	
	factory_ui.building = factory
	factory.ui = factory_ui
	tailor_ui.building = tailor_shop
	tailor_shop.ui = tailor_ui
	
	debug_click_clear_check.toggled.connect(func(v : bool):
		debug_click_clear_enable = v
	)
	debug_click_clear_range_spin.value_changed.connect(func(v : float):
		debug_click_clear_range = int(v)
	)
	debug_click_spawn_check.toggled.connect(func(v : bool):
		debug_click_spawn_enable = v
	)
	debug_click_spawn_option.item_selected.connect(func(idx : int):
		match idx:
			0: debug_click_spawn_name = "Bomb"
			1: debug_click_spawn_name = "Flag"
	)
	
	step_timer.timeout.connect(step)
	refresh_timer.timeout.connect(refresh_board)
	board_size_timer.timeout.connect(update_board_size)
	hover_timer.timeout.connect(update_hover)
