extends RefCounted

class_name StatBlock

var attributes : Dictionary[StringName, Attribute]

func get_attr(n : StringName):
	return attributes[n].get_value()

func add_mod(n : StringName, source, type : int, value, priority : int, category : int = 0):
	attributes[n].add_modifier(source, type, value, priority, category)

func remove_mod(n : StringName, source):
	attributes[n].remove_modifier(source)

func init_attributes(_attrs : Dictionary):
	for n in _attrs.keys():
		var a = Attribute.new()
		a.base_value = _attrs[n]
		attributes[n] = a
