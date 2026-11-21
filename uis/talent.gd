extends Control

class_name UiTalent

@export var frame : PanelContainer
@export var button : TextureButton
@export var txt : Label

var talent : Talent

func setup(t : Talent):
	talent = t

func update_txt():
	if talent:
		txt.text = "%d/%d" % [talent.lv, talent.max_lv]

func update_frame():
	var col = Color.WHITE
	if !talent.is_max_lv():
		if !talent.is_prerequisites_met():
			col = Color.DIM_GRAY
		elif talent.next_lv_cost() <= G.money:
			col = Color.LIME_GREEN
	frame.self_modulate = col

func grant():
	talent.add_points(1)
	update_txt()
	button.mouse_entered.emit()

func _ready() -> void:
	update_txt()
	
	button.texture_normal = G.spell_frames.get_frame_texture(&"default", talent.spell.image_id)
	button.mouse_entered.connect(func():
		var text = "%s (%d/%d):\n" % [talent.name, talent.lv, talent.max_lv]
		if talent.lv > 0:
			text += talent.get_description(talent.lv)
		if !talent.is_max_lv():
			if talent.lv > 0:
				text += "\nNext:\n"
			text += talent.get_description(talent.lv + 1)
			if !talent.costs.is_empty():
				text += "\nCost: %d" % talent.next_lv_cost()
		G.hover_ui.txt.text = text
	)
	button.mouse_exited.connect(func():
		G.hover_ui.txt.text = ""
	)
	button.pressed.connect(func():
		if G.debug_ui.infinite_money:
			grant()
		else:
			if !talent.is_max_lv():
				if talent.is_prerequisites_met():
					var cost = talent.next_lv_cost()
					if G.money >= cost:
						G.set_money(G.money - cost)
						grant()
					else:
						G.add_message("Money")
				else:
					G.add_message("Condition")
	)
	
