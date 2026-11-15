extends RefCounted

class_name StatBlock

var attributes : Dictionary[StringName, Attribute]

func init_attributes(_attrs : Dictionary):
	for n in _attrs.keys():
		var a = Attribute.new()
		a.base_value = _attrs[n]
		attributes[n] = a

func init_attribute_names(attr_names : Array):
	for n in attr_names:
		var a = Attribute.new()
		attributes[n] = a

func get_attr(n : StringName):
	return attributes[n].get_value()

func add_mod(n : StringName, source, type : int, value, priority : int, category : int = 0):
	attributes[n].add_modifier(source, type, value, priority, category)

func remove_mod(n : StringName, source):
	attributes[n].remove_modifier(source)

func transfer_born_stats(target : StatBlock):
	for n in attributes.keys():
		for m in attributes[n].modifiers:
			target.add_mod(n, m.source, m.type, m.value, m.priority, m.category)
