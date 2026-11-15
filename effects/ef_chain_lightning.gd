extends Effect

class_name EfChainLightning

@export var base_power : int = 0
@export var interval : int = 4
@export var falloff : int = 30
@export var max_times : int = 3

const lightning_pb = preload("res://sprites/lightning.tscn")

func start_channeling(caster, env : Dictionary):
	env.times = 0
	var page_range = G.get_board_page_range()
	page_range[1] -= 10
	env.coord = Vector2i(-1, -1)
	env.next_coord = Vector2i(randi_range(0, G.board_width), randf_range(page_range[0], page_range[1]))

func channel(caster, env : Dictionary):
	if env.times < max_times:
		if env.ticks >= env.times * interval:
			if env.next_coord.x != -1:
				var p0 = G.get_position([env.coord]) if env.coord.x != -1 else G.get_ui_pos(caster)
				var p1 = G.get_position([env.next_coord])
				var line = lightning_pb.instantiate()
				line.add_point(p0)
				line.add_point(p1)
				G.vfx.add_child(line)
				var tween = G.create_tween()
				tween.tween_interval(0.1)
				tween.tween_property(line, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_callback(line.queue_free)
				env.coord = env.next_coord
				var cands = []
				var cc = G.offset_to_cube(env.next_coord)
				var cand1 = G.cube_to_offset(cc + Vector3i(0, 1, -1))
				if G.is_valid_coord(cand1) && G.cells[cand1].gem:
					cands.append(cand1)
				var cand2 = G.cube_to_offset(cc + Vector3i(-1, 1, 0))
				if G.is_valid_coord(cand2) && G.cells[cand2].gem:
					cands.append(cand2)
				var cand3 = G.cube_to_offset(cc + Vector3i(1, 0, -1))
				if G.is_valid_coord(cand3) && G.cells[cand3].gem:
					cands.append(cand3)
				if cands.is_empty():
					env.next_coord = Vector2i(-1, -1)
				else:
					env.next_coord = cands.pick_random()
				env.times += 1
