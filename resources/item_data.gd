extends Resource

class_name ItemData

@export var name : String
@export var category : StringName
@export var image_id : int
@export var description : String
@export var max_stack : int = 1
@export var power : int
@export var range : int
@export var spell_names : Array[String]

var dummy : Item = Item.new()
