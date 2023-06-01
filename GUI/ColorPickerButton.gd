extends Button

signal color_picked

var index = 0
var own_color
var is_active = false

func _ready():
	add_theme_stylebox_override("normal", get_theme_stylebox("normal").duplicate())
	add_theme_stylebox_override("hover", get_theme_stylebox("hover").duplicate())
	add_theme_stylebox_override("pressed", get_theme_stylebox("pressed").duplicate())

func set_index(i):
	index = i

func set_color(color):
	own_color = color
	get_theme_stylebox("normal").bg_color = color
	get_theme_stylebox("hover").bg_color = color
	get_theme_stylebox("pressed").bg_color = color

func _on_picker_color_changed(color):
	if is_active:
		set_color(color)
		emit_signal("color_picked", color, index)
