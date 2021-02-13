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

