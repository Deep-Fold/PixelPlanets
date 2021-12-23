extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Galaxy.material.set_shader_param("pixels", amount)
	$Galaxy.rect_size = Vector2(amount, amount) 

func set_light(pos):
	pass

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Galaxy.material.set_shader_param("seed", converted_seed)

func set_rotate(r):
	$Galaxy.material.set_shader_param("rotation", r)

func update_time(t):
	$Galaxy.material.set_shader_param("time", t * get_multiplier($Galaxy.material) * 0.04)

func set_custom_time(t):
	$Galaxy.material.set_shader_param("time", t * PI * 2 * $Galaxy.material.get_shader_param("time_speed"))

func set_dither(d):
	$Galaxy.material.set_shader_param("should_dither", d)

func get_dither():
	return $Galaxy.material.get_shader_param("should_dither")

func get_colors():
	return _get_colors_from_gradient($Galaxy.material, "colorscheme")

func set_colors(colors):
	_set_colors_from_gradient($Galaxy.material, "colorscheme", colors)

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(6 , rand_range(0.5,0.8), 1.4)
	var cols = []
	for i in 6:
		var new_col = seed_colors[i].darkened(i/7.0)
		new_col = new_col.lightened((1.0 - (i/6.0)) * 0.6)
		cols.append(new_col)

	set_colors(cols)
