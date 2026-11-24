extends Control

class_name UiDebug

var click_clear_enable : bool = false
var click_clear_range : int = 0
var click_spawn_enable : bool = false
var click_spawn_id : int = -1
var key_change_color_enable : bool = false
var fast_produce : bool = false
var infinite_money : bool = false
var auto_watch : bool = false
var auto_place : bool = false
var manual : bool = false

@export var click_clear_check : CheckBox
@export var click_clear_range_spin : SpinBox
@export var click_spawn_check : CheckBox
@export var click_spawn_option : OptionButton
@export var key_change_color_check : CheckBox
@export var fast_produce_check : CheckBox
@export var infinite_money_check : CheckBox
@export var auto_watch_check : CheckBox
@export var auto_place_check : CheckBox
@export var manual_check : CheckBox
@export var matched_text : Label

func _ready() -> void:
	click_clear_check.set_pressed_no_signal(click_clear_enable)
	click_clear_check.toggled.connect(func(v : bool):
		click_clear_enable = v
	)
	click_clear_range_spin.value_changed.connect(func(v : float):
		click_clear_range = int(v)
	)
	click_spawn_check.set_pressed_no_signal(click_spawn_enable)
	click_spawn_check.toggled.connect(func(v : bool):
		click_spawn_enable = v
	)
	click_spawn_option.item_selected.connect(func(idx : int):
		click_spawn_id = idx
	)
	key_change_color_check.set_pressed_no_signal(key_change_color_enable)
	key_change_color_check.toggled.connect(func(v : bool):
		key_change_color_enable = v
	)
	fast_produce_check.set_pressed_no_signal(fast_produce)
	fast_produce_check.toggled.connect(func(v : bool):
		fast_produce = v
	)
	infinite_money_check.set_pressed_no_signal(infinite_money)
	infinite_money_check.toggled.connect(func(v : bool):
		infinite_money = v
	)
	auto_watch_check.set_pressed_no_signal(auto_watch)
	auto_watch_check.toggled.connect(func(v : bool):
		auto_watch = v
	)
	auto_place_check.set_pressed_no_signal(auto_place)
	auto_place_check.toggled.connect(func(v : bool):
		auto_place = v
	)
	manual_check.set_pressed_no_signal(manual)
	if manual:
		G.step_timer.stop()
	manual_check.toggled.connect(func(v : bool):
		manual = v
		if v:
			G.step_timer.stop()
		else:
			G.step_timer.start()
	)
