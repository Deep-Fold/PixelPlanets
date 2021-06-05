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


var color_vars1 = ["base_color", "outline_color", "shadow_base_color", "shadow_outline_color"]
var color_vars2 = ["base_color", "outline_color", "shadow_base_color", "shadow_outline_color"]
func get_colors():	
	return (_get_colors_from_vars($Cloud.material, color_vars1) + _get_colors_from_vars($Cloud2.material, color_vars2))

func set_colors(colors):
	_set_colors_from_vars($Cloud.material, color_vars1, colors.slice(0, 3, 1))
	_set_colors_from_vars($Cloud2.material, color_vars2, colors.slice(4, 7, 1))

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(8 + randi()%4, rand_range(0.3, 0.8), 1.0)
	var cols1= []
	var cols2= []
	for i in 4:
		var new_col = seed_colors[i].darkened(i/6.0).darkened(0.7)
#		new_col = new_col.lightened((1.0 - (i/4.0)) * 0.2)
		cols1.append(new_col)
	
	for i in 4:
		var new_col = seed_colors[i+4].darkened(i/4.0)
		new_col = new_col.lightened((1.0 - (i/4.0)) * 0.5)
		cols2.append(new_col)

	set_colors(cols1 + cols2)

