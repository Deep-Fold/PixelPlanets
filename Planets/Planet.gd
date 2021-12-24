extends Control

var time = 1000.0
var override_time = false
var original_colors = []
export (float) var relative_scale = 1.0
export (float) var gui_zoom = 1.0

func _ready():
	original_colors = get_colors()

func set_pixels(_amount):
	pass
func set_light(_pos):
	pass
func set_seed(_sd):
	pass
func set_rotate(_r):
	pass
func update_time(_t):
	pass
func set_custom_time(_t):
	pass

func get_multiplier(mat):
	return (round(mat.get_shader_param("size")) * 2.0) / mat.get_shader_param("time_speed")
	
func _process(delta):
	time += delta	
	if !override_time:
		update_time(time)

func set_dither(_d):
	pass

func get_dither():
	pass

func get_colors():
	return []

func set_colors(_colors):
	pass

func _get_colors_from_gradient(mat, grad_var):
	return mat.get_shader_param(grad_var).gradient.colors

func _set_colors_from_gradient(mat, grad_var, new_gradient):
	mat.get_shader_param(grad_var).gradient.colors = new_gradient

func _get_colors_from_vars(mat, vars):
	var colors = []
	for v in vars:
		colors.append(Color(mat.get_shader_param(v)))
	return colors

func _set_colors_from_vars(mat, vars, colors):
	var index = 0
	for v in vars:
		mat.set_shader_param(v, colors[index])
		index += 1

func randomize_colors():
	pass

# Using ideas from https://www.iquilezles.org/www/articles/palettes/palettes.htm
func _generate_new_colorscheme(n_colors, hue_diff = 0.9, saturation = 0.5):
#	var a = Vector3(rand_range(0.0, 0.5), rand_range(0.0, 0.5), rand_range(0.0, 0.5))
	var a = Vector3(0.5,0.5,0.5)
#	var b = Vector3(rand_range(0.1, 0.6), rand_range(0.1, 0.6), rand_range(0.1, 0.6))
	var b = Vector3(0.5,0.5,0.5) * saturation
	var c = Vector3(rand_range(0.5, 1.5), rand_range(0.5, 1.5), rand_range(0.5, 1.5)) * hue_diff
	var d = Vector3(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0)) * rand_range(1.0, 3.0)

	var cols = PoolColorArray()
	var n = float(n_colors - 1.0)
	n = max(1, n)
	for i in range(0, n_colors, 1):
		var vec3 = Vector3()
		vec3.x = (a.x + b.x *cos(6.28318 * (c.x*float(i/n) + d.x)))
		vec3.y = (a.y + b.y *cos(6.28318 * (c.y*float(i/n) + d.y)))
		vec3.z = (a.z + b.z *cos(6.28318 * (c.z*float(i/n) + d.z)))

		cols.append(Color(vec3.x, vec3.y, vec3.z))
	
	return cols
