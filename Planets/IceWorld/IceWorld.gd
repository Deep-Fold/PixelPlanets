extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$PlanetUnder.material.set_shader_param("pixels", amount)
	$Lakes.material.set_shader_param("pixels", amount)
	$Clouds.material.set_shader_param("pixels", amount)

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
