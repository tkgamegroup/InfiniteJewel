extends RefCounted

class_name Attribute

var base_value
var modifiers : Array[Modifier]
var value
var callbacks : Array[Callable]
var dirty : bool = true

func add_modifier(source, type : int, value, priority : int, category : int = 0):
	var m = Modifier.new()
	m.source = source
	m.type = type
	m.value = value
	m.priority = priority
	m.category = category
	modifiers.insert(modifiers.bsearch_custom(m, func(a : Modifier, b : Modifier):
		return a.priority > b.priority
	, false), m)
	dirty = true

func remove_modifier(source):
	var changed = false
	for i in range(modifiers.size() - 1, -1, -1):
		if modifiers[i].source == source:
			modifiers.remove_at(i)
			changed = true
	if changed:
		dirty = true

func switch(v : int):
	value = v
	for cb in callbacks:
		cb.call(value)

func update():
	value = base_value
	for m in modifiers:
		match m.type:
			Modifier.Type.Flat:
				value += m.value
			Modifier.Type.Pct:
				value *= 1.0 + m.value * 0.01

func get_value():
	if dirty:
		update()
		dirty = false
	return value
