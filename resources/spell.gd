extends Resource

class_name Spell

const type_name : StringName = &"Spell"

@export var name : String
@export var image_id : int
@export var description : String
@export var modifiers : Array[ModifierTarget]
@export var is_aura : bool = false
@export var auto_cast : bool = false
@export var channel_duration : int = -1
@export var channel_tick_effects : Array[Effect]
@export var channel_finished_effects : Array[Effect]

static func is_target_satisfy(target, name : String, category : StringName):
	if !name.is_empty():
		if target.name != name:
			return false
	if !category.is_empty():
		if target.category != category:
			return false
	return true

static func get_targets(type_name : StringName, name : String = "", category : StringName = &"") -> Array[StatBlock]:
	var ret : Array[StatBlock] = []
	match type_name:
		&"Game":
			ret.append(G.stats)
		&"AllGems":
			for y in range(G.board_upper, G.board_lower):
				for x in G.board_width:
					var g = G.cells[Vector2i(x, y)].gem
					if g:
						if is_target_satisfy(g, name, category):
							ret.append(g)
			ret.append(Gem.dummy)
		&"AllItems":
			for i in G.board_items:
				if is_target_satisfy(i, name, category):
					ret.append(i)
			for g in G.warehouse_items:
				for i in g:
					if is_target_satisfy(i, name, category):
						ret.append(i)
			for d in G.item_datas.datas:
				if is_target_satisfy(d, name, category):
					ret.append(d.dummy)
		&"AllPatterns":
			for p in G.patterns:
				if is_target_satisfy(p, name, category):
					ret.append(p)
			for item in G.patterns_ui.on_sells:
				if is_target_satisfy(item[1], name, category):
					ret.append(item[1])
			ret.append(Pattern.dummy)
		&"AllBuildings":
			for b in G.buildings:
				if is_target_satisfy(b, name, category):
					ret.append(b)
			for d in G.building_datas.datas:
				if is_target_satisfy(d, name, category):
					ret.append(d.dummy)
	return ret

func apply_target(t, lv : int, m : ModifierTarget):
	if m.type == Modifier.Type.Switch:
		t.attributes[m.target_attribute].switch(1)
	else:
		t.add_mod(m.target_attribute, self, m.type, m.base_value + m.value_per_lv * lv, m.priority, m.category)

func revert_target(t, m : ModifierTarget):
	if m.type == Modifier.Type.Switch:
		t.attributes[m.target_attribute].switch(0)
	else:
		t.remove_mod(m.target_attribute, self)

func apply(targets : Array, lv : int):
	for m in modifiers:
		if targets.is_empty():
			for t in get_targets(m.target_type, m.target_name, m.target_category):
				apply_target(t, lv, m)
		else:
			for t in targets:
				if t.type_name == m.target_type && is_target_satisfy(t, m.target_name, m.target_category):
					apply_target(t, lv, m)

func revert(targets : Array):
	for m in modifiers:
		if targets.is_empty():
			for t in get_targets(m.target_type, m.target_name, m.target_category):
				revert_target(t, m)
		else:
			for t in targets:
				if t.type_name == m.target_type && is_target_satisfy(t, m.target_name, m.target_category):
					revert_target(t, m)

func get_description(lv : int) -> String:
	return G.format_description(description, self, lv)
