extends "res://Planets/Planet.gd"



func set_pixels(amount):
	$GasLayers.material.set_shader_param("pixels", amount)
	 # times 3 here because in this case ring is 3 times larger than planet
	$Ring.material.set_shader_param("pixels", amount*3.0)

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
