extends "res://Planets/Planet.gd"


func set_pixels(amount):
	$Land.material.set_shader_param("pixels", amount)

func set_light(pos):
	$Land.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Land.material.set_shader_param("seed", converted_seed)
func set_rotate(r):
	$Land.material.set_shader_param("rotation", r)
