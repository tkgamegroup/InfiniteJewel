extends RefCounted

class_name Channeling

var spell : Spell
var ticks : int = 0
var env : Dictionary

func start(caster, s : Spell):
	spell = s
	ticks = 0
	for e in spell.channel_tick_effects:
		e.start_channeling(caster, env)

func step(caster, delta : int):
	for e in spell.channel_tick_effects:
		env.ticks = ticks
		e.channel(caster, env)
	ticks += delta
	if ticks >= spell.channel_duration:
		for e in spell.channel_finished_effects:
			e.excute(caster)
		spell = null
		ticks = 0
		env.clear()
