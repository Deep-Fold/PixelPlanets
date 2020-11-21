extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$PlanetUnder.material.set_shader_param("pixels", amount)
	$Craters.material.set_shader_param("pixels", amount)
	$LavaRivers.material.set_shader_param("pixels", amount)
	
func set_light(pos):
	$PlanetUnder.material.set_shader_param("light_origin", pos)
	$Craters.material.set_shader_param("light_origin", pos)
	$LavaRivers.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$PlanetUnder.material.set_shader_param("seed", converted_seed)
	$Craters.material.set_shader_param("seed", converted_seed)
	$LavaRivers.material.set_shader_param("seed", converted_seed)

func set_rotate(r):
	$PlanetUnder.material.set_shader_param("rotation", r)
	$Craters.material.set_shader_param("rotation", r)
	$LavaRivers.material.set_shader_param("rotation", r)
