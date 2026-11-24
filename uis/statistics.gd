extends Control

class_name UiStatistics

@export var income_txt : Label
@export var damage_txt : Label
@export var reset_button : Button

var accumulated_income : int = 0
var accumulated_damage : int = 0
var samples : Array
var elapsed_ticks : int = 0
var income_per_second : float
var damage_per_second : float

func reset():
	accumulated_income = 0
	accumulated_damage = 0
	samples.clear()

func step():
	elapsed_ticks += 1
	if elapsed_ticks % 10 == 0:
		samples.append([accumulated_income, accumulated_damage])
		accumulated_income = 0
		accumulated_damage = 0
		while samples.size() > 20:
			samples.pop_front()
		income_per_second = 0.0
		damage_per_second = 0.0
		for s in samples:
			income_per_second += s[0]
			damage_per_second += s[1]
		income_per_second /= samples.size()
		damage_per_second /= samples.size()
		income_txt.text = "%0.1f" % income_per_second
		damage_txt.text = "%0.1f" % damage_per_second
		G.quick_stats.text = "IPS: %0.1f\nDPS: %0.1f\n%s" % [income_per_second, damage_per_second, G.format_time(elapsed_ticks)]

func _ready() -> void:
	reset_button.pressed.connect(func():
		reset()
	)
