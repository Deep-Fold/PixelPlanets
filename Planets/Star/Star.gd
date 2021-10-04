extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$StarBackground.material.set_shader_param("pixels", amount*relative_scale)
	$Star.material.set_shader_param("pixels", amount)
	$StarFlares.material.set_shader_param("pixels", amount*relative_scale)

	$Star.rect_size = Vector2(amount, amount)
	$StarFlares.rect_size = Vector2(amount, amount)*relative_scale
	$StarBackground.rect_size = Vector2(amount, amount)*relative_scale

	$StarFlares.rect_position = Vector2(-amount, -amount) * 0.5
	$StarBackground.rect_position = Vector2(-amount, -amount) * 0.5

func set_light(_pos):
	pass

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$StarBackground.material.set_shader_param("seed", converted_seed)
	$Star.material.set_shader_param("seed", converted_seed)
	$StarFlares.material.set_shader_param("seed", converted_seed)

#	removed now with color setting functionality
#	_set_colors(sd)

var starcolor1 = Gradient.new()
var starcolor2 = Gradient.new()
var starflarecolor1 = Gradient.new()
var starflarecolor2 = Gradient.new()

func _ready():
	starcolor1.offsets = [0, 0.33, 0.66, 1.0]
	starcolor2.offsets = [0, 0.33, 0.66, 1.0]
	starflarecolor1.offsets = [0.0, 1.0]
	starflarecolor2.offsets = [0.0, 1.0]
	
	starcolor1.colors = [Color("f5ffe8"), Color("ffd832"), Color("ff823b"), Color("7c191a")]
	starcolor2.colors = [Color("f5ffe8"), Color("77d6c1"), Color("1c92a7"), Color("033e5e")]
	
	starflarecolor1.colors = [Color("ffd832"), Color("f5ffe8")]
	starflarecolor2.colors = [Color("77d6c1"), Color("f5ffe8")]

func _set_colors(sd): # this is just a little extra function to show some different possible stars
	if (sd % 2 == 0):
		$Star.material.get_shader_param("colorramp").gradient = starcolor1
		$StarFlares.material.get_shader_param("colorramp").gradient = starflarecolor1
	else:
		$Star.material.get_shader_param("colorramp").gradient = starcolor2
		$StarFlares.material.get_shader_param("colorramp").gradient = starflarecolor2

func set_rotate(r):
	$StarBackground.material.set_shader_param("rotation", r)
	$Star.material.set_shader_param("rotation", r)
	$StarFlares.material.set_shader_param("rotation", r)

func update_time(t):
	$StarBackground.material.set_shader_param("time", t * get_multiplier($StarBackground.material) * 0.01)
	$Star.material.set_shader_param("time", t * get_multiplier($Star.material) * 0.005)
	$StarFlares.material.set_shader_param("time", t * get_multiplier($StarFlares.material) * 0.015)

func set_custom_time(t):
	$StarBackground.material.set_shader_param("time", t * get_multiplier($StarBackground.material))
	$Star.material.set_shader_param("time", t * (1.0 / $Star.material.get_shader_param("time_speed")))
	$StarFlares.material.set_shader_param("time", t * get_multiplier($StarFlares.material))

func set_dither(d):
	$Star.material.set_shader_param("should_dither", d)
	$StarFlares.material.set_shader_param("should_dither", d)

func get_dither():
	return $Star.material.get_shader_param("should_dither")
	
func get_colors():
	return (PoolColorArray(_get_colors_from_vars($StarBackground.material, ["color"]))
	+ _get_colors_from_gradient($Star.material, "colorramp")
	+ _get_colors_from_gradient($StarFlares.material, "colorramp"))

func set_colors(colors):
	# poolcolorarray doesnt have slice function, convert to generic array first then back to poolcolorarray
	var cols1 = PoolColorArray(Array(colors).slice(1, 4, 1))
	var cols2 = PoolColorArray(Array(colors).slice(5, 6, 1))
	
	$StarBackground.material.set_shader_param("color", colors[0])
	_set_colors_from_gradient($Star.material, "colorramp", cols1)
	_set_colors_from_gradient($StarFlares.material, "colorramp", cols2)

func randomize_colors():
	var seed_colors = _generate_new_colorscheme(4, rand_range(0.2, 0.4), 2.0)
	var cols = []
	for i in 4:
		var new_col = seed_colors[i].darkened((i/4.0) * 0.9)
		new_col = new_col.lightened((1.0 - (i/4.0)) * 0.8)

		cols.append(new_col)
	cols[0] = cols[0].lightened(0.8)

	set_colors([cols[0]] + cols + [cols[1], cols[0]])
