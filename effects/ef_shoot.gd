extends Effect

class_name EfShoot

@export var damage : int = 1

const trail_pb = preload("uid://baxqtvogradvu")

func excute(caster):
	var coord = G.get_board_page_random_coord()
	var pt = trail_pb.instantiate()
	pt.position = G.get_ui_pos(caster)
	G.vfx.add_child(pt)
	var tween = G.create_tween()
	tween.tween_property(pt, "position", G.get_position([coord]), 0.5)
	tween.tween_callback(func():
		G.take_damage(coord, damage, false)
	)
	tween.tween_interval(1.0)
	tween.tween_callback(pt.queue_free)
