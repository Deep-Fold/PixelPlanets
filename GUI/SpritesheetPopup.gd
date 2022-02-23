extends ColorRect

onready var w_frames = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer/WidthFrames
onready var h_frames = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer/HeightFrames
onready var export_button = $PopupFront/VBoxContainer/HBoxContainer/ExportButton
onready var r_info = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer2/ResolutionInfo
onready var f_info = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer2/FrameInfo
onready var warning = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer2/WarningResolution
onready var progressbar = $PopupFront/VBoxContainer/TextureProgress
var pixels = 100
var sheet_size = Vector2(50,1)
var pixel_margin = 0.0

func _on_CancelButton_pressed():
	visible = false

func _on_ExportButton_pressed():
	progressbar.visible = true
	get_parent().export_spritesheet(sheet_size, progressbar, pixel_margin)

func _on_HeightFrames_value_changed(value):
	var val = int(value)
	export_button.disabled = false
	
	if val <= 0:
		export_button.disabled = true
	else:
		sheet_size.y = val
		_update_info()

func _on_WidthFrames_value_changed(value):
	var val = int(value)
	export_button.disabled = false
	
	if val <= 0:
		export_button.disabled = true
	else:
		sheet_size.x = val
		_update_info()

func set_pixels(p):
	
	progressbar.visible = false
	pixels = p
	_update_info()

func _update_info():
	var x_size = sheet_size.x * (pixels + pixel_margin) + pixel_margin
	var y_size = sheet_size.y * (pixels + pixel_margin) + pixel_margin
	
	f_info.text = "Total Frames: %s" % (sheet_size.x*sheet_size.y)
	r_info.text = "Image resolution: \n%sx%s" % [x_size, y_size]
	
	warning.visible = false
	export_button.disabled = false
	
	if x_size > 16384 || y_size > 16384: # max godot image resolution
		warning.visible = true
		export_button.disabled = true


func _on_PixelMargin_value_changed(value):
	pixel_margin = value
	_update_info()
