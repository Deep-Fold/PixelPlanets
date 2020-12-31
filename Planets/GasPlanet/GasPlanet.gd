extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Cloud.material.set_shader_param("pixels", amount)
	$Cloud2.material.set_shader_param("pixels", amount)
	$Cloud.rect_size = Vector2(amount, amount)
	$Cloud2.rect_size = Vector2(amount, amount)

func set_light(pos):
	$Cloud.material.set_shader_param("light_origin", pos)
	$Cloud2.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Cloud.material.set_shader_param("seed", converted_seed)
	$Cloud2.material.set_shader_param("seed", converted_seed)
	$Cloud2.material.set_shader_param("cloud_cover", rand_range(0.28, 0.5))

func set_rotate(r):
	$Cloud.material.set_shader_param("rotation", r)
	$Cloud2.material.set_shader_param("rotation", r)
	
func update_time(t):
	$Cloud.material.set_shader_param("time", t * get_multiplier($Cloud.material) * 0.005)
	$Cloud2.material.set_shader_param("time", t * get_multiplier($Cloud2.material) * 0.005)
	
func set_custom_time(t):
	$Cloud.material.set_shader_param("time", t * get_multiplier($Cloud.material))
	$Cloud2.material.set_shader_param("time", t * get_multiplier($Cloud2.material))
