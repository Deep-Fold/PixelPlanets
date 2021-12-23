extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$GasLayers.material.set_shader_param("pixels", amount)
	 # times 3 here because in this case ring is 3 times larger than planet
	$Ring.material.set_shader_param("pixels", amount*3.0)
	
	$GasLayers.rect_size = Vector2(amount, amount)
	$Ring.rect_position = Vector2(-amount, -amount)
	$Ring.rect_size = Vector2(amount, amount)*3.0

func set_light(pos):
	$GasLayers.material.set_shader_param("light_origin", pos)
	$Ring.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$GasLayers.material.set_shader_param("seed", converted_seed)
	$Ring.material.set_shader_param("seed", converted_seed)

func set_rotate(r):
	$GasLayers.material.set_shader_param("rotation", r)
	$Ring.material.set_shader_param("rotation", r+0.7)

func update_time(t):
	$GasLayers.material.set_shader_param("time", t * get_multiplier($GasLayers.material) * 0.004)
	$Ring.material.set_shader_param("time", t * 314.15 * 0.004)

func set_custom_time(t):
	$GasLayers.material.set_shader_param("time", t * get_multiplier($GasLayers.material))
	$Ring.material.set_shader_param("time", t * 314.15 * $Ring.material.get_shader_param("time_speed") * 0.5)

func set_dither(d):
	$GasLayers.material.set_shader_param("should_dither", d)

func get_dither():
	return $GasLayers.material.get_shader_param("should_dither")

func get_colors():
	return (_get_colors_from_gradient($GasLayers.material, "colorscheme")
	 + _get_colors_from_gradient($Ring.material, "dark_colorscheme"))
	

func set_colors(colors):
	# poolcolorarray doesnt have slice function, convert to generic array first then back to poolcolorarray
	var cols1 = PoolColorArray(Array(colors).slice(0, 2, 1))
	var cols2 = PoolColorArray(Array(colors).slice(3, 5, 1))
	
	_set_colors_from_gradient($GasLayers.material, "colorscheme", cols1)
	_set_colors_from_gradient($Ring.material, "colorscheme", cols1)
	
	_set_colors_from_gradient($GasLayers.material, "dark_colorscheme", cols2)
	_set_colors_from_gradient($Ring.material, "dark_colorscheme", cols2)

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(6 + randi() % 4, rand_range(0.3,0.55), 1.4)
	var cols = []
	for i in 6:
		var new_col = seed_colors[i].darkened(i/7.0)
		new_col = new_col.lightened((1.0 - (i/6.0)) * 0.3)
		cols.append(new_col)

	set_colors(cols)
