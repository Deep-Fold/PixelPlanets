extends Control

onready var planet_holder = $HBoxContainer/PlanetHolder
onready var seedtext = $HBoxContainer/Settings/VBoxContainer/Seed/SeedText
onready var planets = [
	preload("res://Planets/GasPlanet/GasPlanet.tscn"),
	preload("res://Planets/LandMasses/LandMasses.tscn"),
	preload("res://Planets/NoAtmosphere/NoAtmosphere.tscn"),
	preload("res://Planets/Rivers/Rivers.tscn")
]
var pixels = 70.0
var scale = 1.0

func _on_SliderPixels_value_changed(value):
	pixels = value
	planet_holder.get_child(0).set_pixels(value)

func _on_SliderScale_value_changed(value):
	scale = value
	planet_holder.rect_scale = Vector2(1,1)*value

func _on_Control_gui_input(event):
	if (event is InputEventMouseMotion || event is InputEventScreenTouch) && Input.is_action_pressed("mouse"):
		var normal = event.position / Vector2(300, 300)
		planet_holder.get_child(0).set_light(normal)

func _on_LineEdit_text_changed(new_text):
	var new = int(new_text)
	seed(new)
	_create_new_planet()

func _create_new_planet():
	var new_p = planets[randi() % planets.size()].instance()
	new_p.set_seed(randi())
	new_p.set_pixels(pixels)
	planet_holder.get_child(0).queue_free()
	planet_holder.add_child(new_p)

func _seed_random():
	randomize()
	var sd = randi()
	seed(sd)
	seedtext.text = String(sd)
	_create_new_planet()

func _on_Button_pressed():
	_seed_random()

func _process(_delta):
	var time = OS.get_ticks_msec() * 0.001
	$Light.material.set_shader_param("time_elapsed", time)

