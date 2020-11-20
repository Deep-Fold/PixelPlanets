extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Cloud.material.set_shader_param("pixels", amount)
	$Cloud2.material.set_shader_param("pixels", amount)

func set_light(pos):
	$Cloud.material.set_shader_param("light_origin", pos)
	$Cloud2.material.set_shader_param("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Cloud.material.set_shader_param("seed", converted_seed)
	$Cloud2.material.set_shader_param("seed", converted_seed)
	$Cloud2.material.set_shader_param("cloud_cover", rand_range(0.28, 0.5))

func _process(_delta):
	var time = OS.get_ticks_msec() * 0.001
	$Cloud.material.set_shader_param("time_elapsed", time)
	$Cloud2.material.set_shader_param("time_elapsed", time)

