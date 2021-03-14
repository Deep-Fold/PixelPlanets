extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Land.material.set_shader_param("pixels", amount)
	$Cloud.material.set_shader_param("pixels", amount)
	$Land.rect_size = Vector2(amount, amount)
	$Cloud.rect_size = Vector2(amount, amount)

func set_light(pos):
	$Cloud.material.set_shader_param("light_origin", pos)
	$Land.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Cloud.material.set_shader_param("seed", converted_seed)
	$Cloud.material.set_shader_param("cloud_cover", rand_range(0.35, 0.6))
	$Land.material.set_shader_param("seed", converted_seed)

func set_rotate(r):
	$Cloud.material.set_shader_param("rotation", r)
	$Land.material.set_shader_param("rotation", r)

func update_time(t):
	$Cloud.material.set_shader_param("time", t * get_multiplier($Cloud.material) * 0.01)
	$Land.material.set_shader_param("time", t * get_multiplier($Land.material) * 0.02)

func set_custom_time(t):
	$Cloud.material.set_shader_param("time", t * get_multiplier($Cloud.material) * 0.5)
	$Land.material.set_shader_param("time", t * get_multiplier($Land.material))


var color_vars1 = ["col1","col2","col3", "col3", "river_col", "river_col_dark"]
var color_vars2 = ["base_color", "outline_color", "shadow_base_color", "shadow_outline_color"]

func get_colors():
	return (_get_colors_from_vars($Land.material, color_vars1)
	+ _get_colors_from_vars($Cloud.material, color_vars2)
	)

func set_colors(colors):
	_set_colors_from_vars($Land.material, color_vars1, colors.slice(0, 5, 1))
	_set_colors_from_vars($Cloud.material, color_vars2, colors.slice(6, 9, 1))
