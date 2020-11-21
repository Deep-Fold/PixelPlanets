extends Control

onready var viewport = $PlanetViewport
onready var viewport_holder = $PlanetHolder
onready var seedtext = $Settings/VBoxContainer/Seed/SeedText
onready var optionbutton = $Settings/VBoxContainer/OptionButton

onready var planets = {
	"Terran Wet": preload("res://Planets/Rivers/Rivers.tscn"),
	"Terran Dry": preload("res://Planets/DryTerran/DryTerran.tscn"),	
	"Islands": preload("res://Planets/LandMasses/LandMasses.tscn"),
	"No atmosphere": preload("res://Planets/NoAtmosphere/NoAtmosphere.tscn"),
	"Gas giant 1": preload("res://Planets/GasPlanet/GasPlanet.tscn"),
	"Gas giant 2": preload("res://Planets/GasPlanetLayers/GasPlanetLayers.tscn"),
	"Ice World": preload("res://Planets/IceWorld/IceWorld.tscn"),
	"Lava World": preload("res://Planets/LavaWorld/LavaWorld.tscn"),
}
var pixels = 100.0
var scale = 1.0
var sd = 0

func _ready():
	for k in planets.keys():
		optionbutton.add_item(k)

func _on_OptionButton_item_selected(index):
	var chosen = planets[planets.keys()[index]]
	_create_new_planet(chosen)

func _on_SliderPixels_value_changed(value):
	pixels = value
	viewport.get_child(0).set_pixels(value)

func _on_SliderScale_value_changed(value):
	scale = value
	viewport_holder.rect_scale = Vector2(1,1)*value

func _on_SliderRotation_value_changed(value):
	viewport.get_child(0).set_rotate(value)
	

func _on_Control_gui_input(event):
	if (event is InputEventMouseMotion || event is InputEventScreenTouch) && Input.is_action_pressed("mouse"):
		var normal = event.position / Vector2(300, 300)
		viewport.get_child(0).set_light(normal)

func _on_LineEdit_text_changed(new_text):
	call_deferred("_make_from_seed", int(new_text))

func _make_from_seed(new_seed):
	sd = new_seed
	seed(sd)
	viewport.get_child(0).set_seed(sd)

func _create_new_planet(type):
	for c in viewport.get_children():
		c.queue_free()
	
	var new_p = type.instance()
	seed(sd)
	new_p.set_seed(randi())
	new_p.set_pixels(pixels)
	new_p.rect_position = Vector2(200,200)
	viewport.add_child(new_p)

func _seed_random():
	randomize()
	sd = randi()
	seed(sd)
	seedtext.text = String(sd)
	viewport.get_child(0).set_seed(sd)

func _on_Button_pressed():
	_seed_random()


func _on_ExportPNG_pressed():
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		var err = viewport.get_texture().get_data().save_png("res://%s.png"%String(sd))
		prints(err)
	else:
		var image = viewport.get_texture().get_data()
		var filesaver = get_tree().root.get_node("/root/HTML5File")
		filesaver.save_image(image, String(sd))
