extends Control

@export var button : TextureButton
@export var txt : Label

var talent : Talent

func setup(t : Talent):
	talent = t

func update_txt():
	if talent:
		txt.text = "%d/%d" % [talent.lv, talent.max_lv]

func _ready() -> void:
	update_txt()
	
	button.mouse_entered.connect(func():
		G.hover_ui.txt.text = talent.description
	)
	button.mouse_exited.connect(func():
		G.hover_ui.txt.text = ""
	)
	button.pressed.connect(func():
		if talent.lv < talent.max_lv:
			talent.add_points(1)
			update_txt()
	)
	
