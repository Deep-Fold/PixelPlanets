extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$PlanetUnder.material.set_shader_parameter("pixels", amount)
	$Craters.material.set_shader_parameter("pixels", amount)

	$PlanetUnder.size = Vector2(amount, amount)
	$Craters.size = Vector2(amount, amount)

func set_light(pos):
	$PlanetUnder.material.set_shader_parameter("light_origin", pos)
	$Craters.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$PlanetUnder.material.set_shader_parameter("seed", converted_seed)
	$Craters.material.set_shader_parameter("seed", converted_seed)

func set_rotate(r):
	$PlanetUnder.material.set_shader_parameter("rotation", r)
	$Craters.material.set_shader_parameter("rotation", r)

func update_time(t):
	$PlanetUnder.material.set_shader_parameter("time", t * get_multiplier($PlanetUnder.material) * 0.02)
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material) * 0.02)

func set_custom_time(t):
	$PlanetUnder.material.set_shader_parameter("time", t * get_multiplier($PlanetUnder.material))
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material))
