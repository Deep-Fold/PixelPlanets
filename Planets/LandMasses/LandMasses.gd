extends "res://Planets/Planet.gd"

func set_pixels(amount):	
	$Water.material.set_shader_param("pixels", amount)
	$Land.material.set_shader_param("pixels", amount)
	$Cloud.material.set_shader_param("pixels", amount)

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
