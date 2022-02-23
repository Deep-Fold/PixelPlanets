extends Control

onready var viewport = $PlanetViewport
onready var viewport_planet = $PlanetViewport/PlanetHolder
onready var viewport_holder = $PlanetHolder
onready var viewport_tex = $PlanetHolder/ViewportTexture
onready var seedtext = $Settings/VBoxContainer/Seed/SeedText
onready var optionbutton = $Settings/VBoxContainer/OptionButton
onready var colorholder = $Settings/VBoxContainer/ColorButtonHolder
onready var picker = $Panel/ColorPicker
onready var random_colors = $Settings/VBoxContainer/HBoxContainer/RandomizeColors
onready var dither_button = $Settings/VBoxContainer/HBoxContainer2/ShouldDither

onready var colorbutton_scene = preload("res://GUI/ColorPickerButton.tscn")


const GIFExporter = preload("res://addons/gdgifexporter/exporter.gd")
const MedianCutQuantization = preload("res://addons/gdgifexporter/quantization/median_cut.gd")

onready var planets = {
	"Terran Wet": preload("res://Planets/Rivers/Rivers.tscn"),
	"Terran Dry": preload("res://Planets/DryTerran/DryTerran.tscn"),	
	"Islands": preload("res://Planets/LandMasses/LandMasses.tscn"),
	"No atmosphere": preload("res://Planets/NoAtmosphere/NoAtmosphere.tscn"),
	"Gas giant 1": preload("res://Planets/GasPlanet/GasPlanet.tscn"),
	"Gas giant 2": preload("res://Planets/GasPlanetLayers/GasPlanetLayers.tscn"),
	"Ice World": preload("res://Planets/IceWorld/IceWorld.tscn"),
	"Lava World": preload("res://Planets/LavaWorld/LavaWorld.tscn"),
	"Asteroid": preload("res://Planets/Asteroids/Asteroid.tscn"),
	"Black Hole": preload("res://Planets/BlackHole/BlackHole.tscn"),
	"Galaxy": preload("res://Planets/Galaxy/Galaxy.tscn"),
	"Star": preload("res://Planets/Star/Star.tscn"),
}
var pixels = 100.0
var scale = 1.0
var sd = 0
var colors = []
var should_dither = true

func _ready():
	for k in planets.keys():
		optionbutton.add_item(k)

	_seed_random()
	_create_new_planet(planets["Terran Wet"])
#	yield(get_tree(), "idle_frame")
#	viewport.size = Vector2(pixels, pixels)


func _on_OptionButton_item_selected(index):
	var chosen = planets[planets.keys()[index]]
	_create_new_planet(chosen)
	_close_picker()

func _on_SliderRotation_value_changed(value):
	viewport_planet.get_child(0).set_rotate(value)

func _on_Control_gui_input(event):
	if (event is InputEventMouseMotion || event is InputEventScreenTouch) && Input.is_action_pressed("mouse"):
		var normal = event.position / Vector2(300, 300)
		viewport_planet.get_child(0).set_light(normal)
		
		if $Panel.visible:
			_close_picker()

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
	viewport_planet.add_child(new_p)
	
	seed(sd)
	new_p.set_seed(sd)
	new_p.set_pixels(pixels)
	new_p.rect_position = pixels * 0.5 * (new_p.relative_scale -1) * Vector2(1,1)
	new_p.set_dither(should_dither)
	
	colors = new_p.get_colors()
	_make_color_buttons()

	yield(get_tree(), "idle_frame")
	viewport.size = Vector2(pixels, pixels) * new_p.relative_scale
	
	# some hardcoded values that look good in the GUI
	match new_p.gui_zoom:
		1.0:
			viewport_tex.rect_position = Vector2(50,50)
			viewport_tex.rect_size = Vector2(200,200)
		2.0:
			viewport_tex.rect_position = Vector2(25,25)
			viewport_tex.rect_size = Vector2(250,250)
		2.5:
			viewport_tex.rect_position = Vector2(0,0)
			viewport_tex.rect_size = Vector2(300,300)


func _make_color_buttons():
	for b in colorholder.get_children():
		b.queue_free()
	
	for i in colors.size():
		var b = colorbutton_scene.instance()
		b.set_color(colors[i])
		b.set_index(i)
		b.connect("color_picked", self, "_on_colorbutton_color_picked")
		b.connect("button_pressed", self, "_on_colorbutton_pressed")
		picker.connect("color_changed", b, "_on_picker_color_changed")
		
		colorholder.add_child(b)

func _on_colorbutton_pressed(button):
	for b in colorholder.get_children():
		b.is_active = false
	button.is_active = true
	$Panel.visible = true
	picker.color = button.own_color

func _on_colorbutton_color_picked(color, index):
	colors[index] = color
	viewport_planet.get_child(0).set_colors(colors)

func _seed_random():
	randomize()
	sd = randi()
	seed(sd)
	seedtext.text = String(sd)
	viewport_planet.get_child(0).set_seed(sd)

func _on_Button_pressed():
	_seed_random()

func _on_ExportPNG_pressed():
	var planet = viewport_planet.get_child(0)
	var tex = viewport.get_texture().get_data()
	var image = Image.new()
	image.create(pixels * planet.relative_scale, pixels * planet.relative_scale, false, Image.FORMAT_RGBA8)
	var source_xy = 0
	var source_size = pixels*planet.relative_scale
	var source_rect = Rect2(source_xy, source_xy,source_size,source_size)
	image.blit_rect(tex, source_rect, Vector2(0,0))
	
	save_image(image)

func export_spritesheet(sheet_size, progressbar, pixel_margin = 0.0):
	var planet = viewport_planet.get_child(0)
	var sheet = Image.new()
	progressbar.max_value = sheet_size.x * sheet_size.y
	
	sheet.create(pixels * sheet_size.x * planet.relative_scale + sheet_size.x*pixel_margin + pixel_margin,
				pixels * sheet_size.y * planet.relative_scale + sheet_size.y*pixel_margin + pixel_margin,
				false, Image.FORMAT_RGBA8)
	planet.override_time = true
	
	var index = 0
	for y in range(sheet_size.y):
		for x in range(sheet_size.x + 1):
			planet.set_custom_time(lerp(0.0, 1.0, (index)/float((sheet_size.x+1) * sheet_size.y)))
			yield(get_tree(), "idle_frame")
			
			if index != 0:
				var image = viewport.get_texture().get_data()
				var source_xy = 0
				var source_size = pixels*planet.relative_scale
				var source_rect = Rect2(source_xy, source_xy,source_size,source_size)
				var destination = Vector2(x - 1,y) * pixels * planet.relative_scale + Vector2(x * pixel_margin, (y+1) * pixel_margin)
				sheet.blit_rect(image, source_rect, destination)

			index +=1
			progressbar.value = index
	
	
	planet.override_time = false
	save_image(sheet)
	$Popup.visible = false

func save_image(img):
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		JavaScript.download_buffer(img.save_png_to_buffer(), String(sd)+".png", "image/png")
	else:
		if OS.get_name() == "OSX":
			img.save_png("user://%s.png"%String(sd))
		else:
			img.save_png("res://%s.png"%String(sd))

func _on_ExportSpriteSheet_pressed():
	$Panel.visible = false
	$Popup.visible = true
	$Popup.set_pixels(pixels * viewport_planet.get_child(0).relative_scale)

func _on_PickerExit_pressed():
	_close_picker()

func _close_picker():
	$Panel.visible = false
	for b in colorholder.get_children():
		b.is_active = false


func _on_RandomizeColors_pressed():
	viewport_planet.get_child(0).randomize_colors()
	colors = viewport_planet.get_child(0).get_colors()
	for i in colorholder.get_child_count():
		colorholder.get_child(i).set_color(colors[i])


func _on_ResetColors_pressed():
	viewport_planet.get_child(0).set_colors(viewport_planet.get_child(0).original_colors)
	colors = viewport_planet.get_child(0).get_colors()
	for i in colorholder.get_child_count():
		colorholder.get_child(i).set_color(colors[i])

func _on_ShouldDither_pressed():
	should_dither = !should_dither
	if should_dither:
		dither_button.text = "On"
	else:
		dither_button.text = "Off"
	viewport_planet.get_child(0).set_dither(should_dither)


func _on_ExportGIF_pressed():
	$GifPopup.visible = true
	cancel_gif = false

var cancel_gif = false
func export_gif(frames, frame_delay, progressbar):
	var planet = viewport_planet.get_child(0)
	var exporter = GIFExporter.new(pixels*planet.relative_scale, pixels*planet.relative_scale)
	progressbar.max_value = frames
	
	planet.override_time = true
	planet.set_custom_time(0.0)
	yield(get_tree(), "idle_frame")
	
	for i in range(frames):
		if cancel_gif:
			progressbar.value = 0
			planet.override_time = false
			break;
			return;
		
		planet.set_custom_time(lerp(0.0, 1.0, float(i)/float(frames)))

		yield(get_tree(), "idle_frame")
		
		var tex = viewport.get_texture().get_data()
		var image = Image.new()
		image.create(pixels * planet.relative_scale, pixels * planet.relative_scale, false, Image.FORMAT_RGBA8)
		
		var source_xy = 0
		var source_size = pixels*planet.relative_scale
		var source_rect = Rect2(source_xy, source_xy,source_size,source_size)
		image.blit_rect(tex, source_rect, Vector2(0,0))
		exporter.add_frame(image, frame_delay, MedianCutQuantization)
		
		progressbar.value = i
	
	if cancel_gif:
		return
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		var file: File = File.new()
		if OS.get_name() == "OSX":
			file.open("user://%s.gif"%String(sd), File.WRITE)
		else:
			file.open("res://%s.gif"%String(sd), File.WRITE)
		file.store_buffer(exporter.export_file_data())
		file.close()
	else:
		var data = Array(exporter.export_file_data())
		JavaScript.download_buffer(data, String(sd)+".gif", "image/gif")

	planet.override_time = false
	$GifPopup.visible = false
	progressbar.visible = false


func _on_GifPopup_cancel_gif():
	cancel_gif = true

func _on_InputPixels_text_changed(text):
	pixels = int(text)
	pixels = clamp(pixels, 12, 5000)
	if (int(text) > 5000):
		$Settings/VBoxContainer/InputPixels.text = String(pixels)
	
	var p = viewport_planet.get_child(0)
	p.set_pixels(pixels)
	
	p.rect_position = pixels * 0.5 * (p.relative_scale -1) * Vector2(1,1)

	yield(get_tree(), "idle_frame")
	viewport.size = Vector2(pixels, pixels) * p.relative_scale
