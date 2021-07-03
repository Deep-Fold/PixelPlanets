extends "res://Planets/Planet.gd"

func set_pixels(amount):	
	$Water.material.set_shader_param("pixels", amount)
	$Land.material.set_shader_param("pixels", amount)
	$Cloud.material.set_shader_param("pixels", amount)
	
	$Water.rect_size = Vector2(amount, amount)
	$Land.rect_size = Vector2(amount, amount)
	$Cloud.rect_size = Vector2(amount, amount)

func set_light(pos):
	$Cloud.material.set_shader_param("light_origin", pos)
	$Water.material.set_shader_param("light_origin", pos)
	$Land.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Cloud.material.set_shader_param("seed", converted_seed)
	$Water.material.set_shader_param("seed", converted_seed)
	$Land.material.set_shader_param("seed", converted_seed)
	$Cloud.material.set_shader_param("cloud_cover", rand_range(0.35, 0.6))

func set_rotate(r):
	$Cloud.material.set_shader_param("rotation", r)
	$Water.material.set_shader_param("rotation", r)
	$Land.material.set_shader_param("rotation", r)

func update_time(t):
	$Cloud.material.set_shader_param("time", t * get_multiplier($Cloud.material) * 0.01)
	$Water.material.set_shader_param("time", t * get_multiplier($Water.material) * 0.02)
	$Land.material.set_shader_param("time", t * get_multiplier($Land.material) * 0.02)

func set_custom_time(t):
	$Cloud.material.set_shader_param("time", t * get_multiplier($Cloud.material))
	$Water.material.set_shader_param("time", t * get_multiplier($Water.material))
	$Land.material.set_shader_param("time", t * get_multiplier($Land.material))

func set_dither(d):
	$Water.material.set_shader_param("should_dither", d)

func get_dither():
	return $Water.material.get_shader_param("should_dither")

var color_vars1 = ["color1","color2","color3"]
var color_vars2 = ["col1","col2","col3", "col4"]
var color_vars3 = ["base_color", "outline_color", "shadow_base_color", "shadow_outline_color"]

func get_colors():
	return (_get_colors_from_vars($Water.material, color_vars1)
	+ _get_colors_from_vars($Land.material, color_vars2)
	+ _get_colors_from_vars($Cloud.material, color_vars3)
	)

func set_colors(colors):
	_set_colors_from_vars($Water.material, color_vars1, colors.slice(0, 2, 1))
	_set_colors_from_vars($Land.material, color_vars2, colors.slice(3, 6, 1))
	_set_colors_from_vars($Cloud.material, color_vars3, colors.slice(7, 10, 1))

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(randi()%2+3, rand_range(0.7, 1.0), rand_range(0.45, 0.55))
	var land_colors = []
	var water_colors = []
	var cloud_colors = []
	for i in 4:
		var new_col = seed_colors[0].darkened(i/4.0)
		land_colors.append(Color.from_hsv(new_col.h + (0.2 * (i/4.0)), new_col.s, new_col.v))
	
	for i in 3:
		var new_col = seed_colors[1].darkened(i/5.0)
		water_colors.append(Color.from_hsv(new_col.h + (0.1 * (i/2.0)), new_col.s, new_col.v))
	
	for i in 4:
		var new_col = seed_colors[2].lightened((1.0 - (i/4.0)) * 0.8)
		cloud_colors.append(Color.from_hsv(new_col.h + (0.2 * (i/4.0)), new_col.s, new_col.v))

	set_colors(water_colors + land_colors + cloud_colors)
