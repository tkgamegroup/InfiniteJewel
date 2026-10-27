extends Control

@export var button : TextureButton
@export var number : Label

var item : Item = null

func _ready() -> void:
	button.mouse_entered.connect(func():
		G.hover_ui.txt.text = ""
	)
	button.mouse_exited.connect(func():
		G.hover_ui.txt.text = ""
	)
