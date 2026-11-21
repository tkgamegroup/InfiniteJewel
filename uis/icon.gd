extends Control

class_name UiIcon

@export var button : TextureButton
@export var number : Label

var is_button : bool = false
var obj
var extra_tooltip_cb : Callable

func setup(_obj):
	obj = _obj

func set_pressed(cb : Callable):
	is_button = true
	button.pressed.connect(cb)

func _ready() -> void:
	match obj.type_name:
		&"Item":
			button.texture_normal = G.board_ui.get_tile_texture(obj.get_data().image_id)
		&"Tech":
			button.texture_normal = G.spell_frames.get_frame_texture(&"default", obj.spell.image_id)
		&"Spell":
			button.texture_normal = G.spell_frames.get_frame_texture(&"default", obj.image_id)
	
	button.mouse_entered.connect(func():
		if is_button:
			self.self_modulate.a = 1.0
		var text = obj.get_description(-1)
		if !extra_tooltip_cb.is_null():
			text += extra_tooltip_cb.call()
		G.hover_ui.txt.text = text
	)
	button.mouse_exited.connect(func():
		if is_button:
			self.self_modulate.a = 0.0
		G.hover_ui.txt.text = ""
	)
