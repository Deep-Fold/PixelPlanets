extends "res://Planets/Planet.gd"



func set_pixels(amount):
	$BlackHole.material.set_shader_param("pixels", amount)
	 # times 3 here because in this case ring is 3 times larger than planet
	$Disk.material.set_shader_param("pixels", amount*3.0)
	
	$BlackHole.rect_size = Vector2(amount, amount)
	$Disk.rect_position = Vector2(-amount, -amount)
	$Disk.rect_size = Vector2(amount, amount)*3.0

func set_light(_pos):
	pass

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Disk.material.set_shader_param("seed", converted_seed)

func set_rotate(r):
	$Disk.material.set_shader_param("rotation", r+0.7)

func update_time(t):
	$Disk.material.set_shader_param("time", t * 314.15 * 0.004 )

func set_custom_time(t):
	$Disk.material.set_shader_param("time", t * 314.15 * $Disk.material.get_shader_param("time_speed") * 0.5)

func set_dither(d):
	$Disk.material.set_shader_param("should_dither", d)

func get_dither():
	return $Disk.material.get_shader_param("should_dither")

func get_colors():
	return (PoolColorArray([$BlackHole.material.get_shader_param("black_color")]) + _get_colors_from_gradient($BlackHole.material, "colorscheme") + _get_colors_from_gradient($Disk.material, "colorscheme"))
	
func set_colors(colors):
	# poolcolorarray doesnt have slice function, convert to generic array first then back to poolcolorarray
	var cols1 = PoolColorArray(Array(colors).slice(1, 2))
	var cols2 = PoolColorArray(Array(colors).slice(3, 7))
	
	$BlackHole.material.set_shader_param("black_color", colors[0])
	_set_colors_from_gradient($BlackHole.material, "colorscheme", cols1)
	_set_colors_from_gradient($Disk.material, "colorscheme", cols2)

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(5 + randi()%2, rand_range(0.3, 0.5), 2.0)
	var cols= []
	for i in 5:
		var new_col = seed_colors[i].darkened((i/5.0) * 0.7)
		new_col = new_col.lightened((1.0 - (i/5.0)) * 0.9)

		cols.append(new_col)

	set_colors([Color("272736")] + [cols[0], cols[3]] + cols)
