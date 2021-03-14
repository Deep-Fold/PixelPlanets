extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$PlanetUnder.material.set_shader_param("pixels", amount)
	$Lakes.material.set_shader_param("pixels", amount)
	$Clouds.material.set_shader_param("pixels", amount)
	
	$PlanetUnder.rect_size = Vector2(amount, amount)
	$Lakes.rect_size = Vector2(amount, amount)
	$Clouds.rect_size = Vector2(amount, amount)

func set_light(pos):
	$PlanetUnder.material.set_shader_param("light_origin", pos)
	$Lakes.material.set_shader_param("light_origin", pos)
	$Clouds.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$PlanetUnder.material.set_shader_param("seed", converted_seed)
	$Lakes.material.set_shader_param("seed", converted_seed)
	$Clouds.material.set_shader_param("seed", converted_seed)

func set_rotate(r):
	$PlanetUnder.material.set_shader_param("rotation", r)
	$Lakes.material.set_shader_param("rotation", r)
	$Clouds.material.set_shader_param("rotation", r)

func update_time(t):
	$PlanetUnder.material.set_shader_param("time", t * get_multiplier($PlanetUnder.material) * 0.02)
	$Lakes.material.set_shader_param("time", t * get_multiplier($Lakes.material) * 0.02)
	$Clouds.material.set_shader_param("time", t * get_multiplier($Clouds.material) * 0.01)

func set_custom_time(t):
	$PlanetUnder.material.set_shader_param("time", t * get_multiplier($PlanetUnder.material))
	$Lakes.material.set_shader_param("time", t * get_multiplier($Lakes.material))
	$Clouds.material.set_shader_param("time", t * get_multiplier($Clouds.material))

var color_vars1 = ["color1","color2","color3"]
var color_vars2 = ["color1","color2","color3"]
var color_vars3 = ["base_color", "outline_color", "shadow_base_color", "shadow_outline_color"]

func get_colors():
	return (_get_colors_from_vars($PlanetUnder.material, color_vars1)
	+ _get_colors_from_vars($Lakes.material, color_vars2)
	+ _get_colors_from_vars($Clouds.material, color_vars3)
	)

func set_colors(colors):
	_set_colors_from_vars($PlanetUnder.material, color_vars1, colors.slice(0, 2, 1))
	_set_colors_from_vars($Lakes.material, color_vars2, colors.slice(3, 5, 1))
	_set_colors_from_vars($Clouds.material, color_vars3, colors.slice(6, 9, 1))
