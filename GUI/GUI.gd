extends Control

onready var viewport = $PlanetViewport
onready var viewport_planet = $PlanetViewport/PlanetHolder
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
const max_pixel_size = 100.0;
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
	viewport_planet.get_child(0).set_pixels(value)
	viewport_holder.rect_scale = Vector2(2,2) * max_pixel_size/pixels
	#viewport_holder.rect_position = Vector2(1,1) * max_pixel_size/pixels - Vector2(200,200)
	$Settings/VBoxContainer/Label3.text = "Pixels: " + String(pixels) + "x" + String(pixels)

func _on_SliderScale_value_changed(value):
	scale = value
	viewport_holder.rect_scale = Vector2(1,1)*value

func _on_SliderRotation_value_changed(value):
	viewport_planet.get_child(0).set_rotate(value)

func _on_Control_gui_input(event):
	if (event is InputEventMouseMotion || event is InputEventScreenTouch) && Input.is_action_pressed("mouse"):
		var normal = event.position / Vector2(300, 300)
		viewport_planet.get_child(0).set_light(normal)

func _on_LineEdit_text_changed(new_text):
	call_deferred("_make_from_seed", int(new_text))

func _make_from_seed(new_seed):
	sd = new_seed
	seed(sd)
	viewport_planet.get_child(0).set_seed(sd)

func _create_new_planet(type):
	for c in viewport_planet.get_children():
		c.queue_free()
	
	var new_p = type.instance()
	seed(sd)
	new_p.set_seed(randi())
	new_p.set_pixels(pixels)
	new_p.rect_position = Vector2(0,0)
	viewport_planet.add_child(new_p)

func _seed_random():
	randomize()
	sd = randi()
	seed(sd)
	seedtext.text = String(sd)
	viewport_planet.get_child(0).set_seed(sd)

func _on_Button_pressed():
	_seed_random()


func _on_ExportPNG_pressed():
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		var err = viewport.get_texture().get_data().save_png("res://%s.png"%String(sd))
		prints(err)
	else:
		var planet = viewport_planet.get_child(0)
		var tex = viewport.get_texture().get_data()
		var image = Image.new()
		image.create(pixels * planet.relative_scale, pixels * planet.relative_scale, false, Image.FORMAT_RGBA8)
		var source_xy = 100 - (pixels*(planet.relative_scale-1)*0.5)
		var source_size = 100*planet.relative_scale
		var source_rect = Rect2(source_xy, source_xy,source_size,source_size)
		image.blit_rect(tex, source_rect, Vector2(0,0))
		
		var filesaver = get_tree().root.get_node("/root/HTML5File")
		filesaver.save_image(image, String(sd))

func export_spritesheet(sheet_size, progressbar):
	var planet = viewport_planet.get_child(0)
	var sheet = Image.new()
	progressbar.max_value = sheet_size.x * sheet_size.y
	
	sheet.create(pixels * sheet_size.x * planet.relative_scale, pixels * sheet_size.y * planet.relative_scale, false, Image.FORMAT_RGBA8)
	planet.override_time = true
	
	var index = 0
	for y in range(sheet_size.y):
		for x in range(sheet_size.x + 1):
			planet.set_custom_time(lerp(0.0, 1.0, (index)/float((sheet_size.x+1) * sheet_size.y)))
			yield(get_tree(), "idle_frame")
			
			if index != 0:
				var image = viewport.get_texture().get_data()
				var source_xy = 100 - (pixels*(planet.relative_scale-1)*0.5)
				var source_size = 100*planet.relative_scale
				var source_rect = Rect2(source_xy, source_xy,source_size,source_size)
				var destination = Vector2(x - 1,y) * pixels * planet.relative_scale
				sheet.blit_rect(image, source_rect, destination)

			index +=1
			progressbar.value = index
	
	
	planet.override_time = false
	var filesaver = get_tree().root.get_node("/root/HTML5File")
	filesaver.save_image(sheet, String(sd))
	$Popup.visible = false


func _on_ExportSpriteSheet_pressed():
	$Popup.visible = true
	$Popup.set_pixels(pixels * viewport_planet.get_child(0).relative_scale)
