extends Control

var time = 1000.0
var override_time = false
export (float) var relative_scale = 1.0


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
