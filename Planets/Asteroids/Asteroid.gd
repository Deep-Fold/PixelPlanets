extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Asteroid.material.set_shader_param("pixels", amount)
	$Asteroid.rect_size = Vector2(amount, amount)

func set_light(pos):
	$Asteroid.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Asteroid.material.set_shader_param("seed", converted_seed)

func set_rotate(r):
	$Asteroid.material.set_shader_param("rotation", r)

func update_time(_t):
	pass

func set_custom_time(t):
	$Asteroid.material.set_shader_param("rotation", t * PI * 2.0)

func set_dither(d):
	$Asteroid.material.set_shader_param("should_dither", d)

func get_dither():
	return $Asteroid.material.get_shader_param("should_dither")

var color_vars = ["color1", "color2", "color3"]
func get_colors():
	return _get_colors_from_vars($Asteroid.material, color_vars)

func set_colors(colors):
	_set_colors_from_vars($Asteroid.material, color_vars, colors)

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(3 + randi()%2, rand_range(0.3, 0.6), 0.7)
	var cols= []
	for i in 3:
		var new_col = seed_colors[i].darkened(i/3.0)
		new_col = new_col.lightened((1.0 - (i/3.0)) * 0.2)

		cols.append(new_col)

	set_colors(cols)
