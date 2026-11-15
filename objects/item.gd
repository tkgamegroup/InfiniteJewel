extends StatBlock

class_name Item

const type_name : StringName = &"Item"

var res_id : int = -1
var name : String
var category : StringName

var coord : Vector2i
var ticks : int
var spells : Array[Spell]
var channeling : Channeling = Channeling.new()

func _init() -> void:
	init_attributes({&"power":0,&"range":0})

func get_data() -> ItemData:
	if res_id == -1:
		return null
	return G.item_datas.datas[res_id]

func is_aura():
	for s in spells:
		if s.is_aura:
			return true
	return false

func setup(id : int):
	assert(id != -1)
	res_id = id
	var d = get_data()
	name = d.name
	category = d.category
	attributes[&"power"].base_value = d.power
	attributes[&"range"].base_value = d.range
	for n in d.spell_names:
		var spell = G.spells.find_data(n)
		assert(spell)
		spells.append(spell)
	d.dummy.transfer_born_stats(self)

func setup_by_name(n : String):
	setup(G.item_datas.find(n))

func get_description(unused : int) -> String:
	return G.format_description(get_data().description, self)

func on_placed():
	for s in spells:
		if s.auto_cast:
			if s.channel_duration != -1:
				channeling.start(self, s)

func step():
	if channeling.spell:
		channeling.step(self, 1)
