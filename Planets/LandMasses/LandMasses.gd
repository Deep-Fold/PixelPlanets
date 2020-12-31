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
