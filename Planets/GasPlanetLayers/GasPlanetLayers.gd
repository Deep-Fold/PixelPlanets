extends "res://Planets/Planet.gd"



func set_pixels(amount):
	$GasLayers.material.set_shader_param("pixels", amount)
	 # times 3 here because in this case ring is 3 times larger than planet
	$Ring.material.set_shader_param("pixels", amount*3.0)
	
	$GasLayers.rect_size = Vector2(amount, amount)
	$Ring.rect_position = Vector2(-amount, -amount)
	$Ring.rect_size = Vector2(amount, amount)*3.0

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

func update_time(t):
	$GasLayers.material.set_shader_param("time", t * get_multiplier($GasLayers.material) * 0.004)
	$Ring.material.set_shader_param("time", t * 314.15 * 0.004)

func set_custom_time(t):
	$GasLayers.material.set_shader_param("time", t * get_multiplier($GasLayers.material))
	$Ring.material.set_shader_param("time", t * 314.15 * $Ring.material.get_shader_param("time_speed") * 0.5)
