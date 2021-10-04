extends ColorRect
signal cancel_gif


onready var export_button = $PopupFront/VBoxContainer/HBoxContainer/ExportButton
onready var progressbar = $PopupFront/VBoxContainer/TextureProgress
onready var set_framecount = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer/GifFrameCount
onready var set_giftime = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer/GifTime
onready var set_delay = $PopupFront/VBoxContainer/SpritesheetSettings/VBoxContainer/FrameDelay


onready var frames = 60
onready var length = 10
onready var frame_delay = 0.167

func _on_CancelButton_pressed():
	visible = false
	emit_signal("cancel_gif")

func _on_ExportButton_pressed():
	progressbar.visible = true
	get_parent().export_gif(frames, frame_delay, progressbar)

func _on_FrameDelay_value_changed(value):
	frame_delay = value
	length = frames * frame_delay
	
	set_giftime.disconnect("value_changed", self, "_on_GifTime_value_changed")
	set_giftime.value = length
	set_giftime.connect("value_changed", self, "_on_GifTime_value_changed")

func _on_GifTime_value_changed(value):
	length = value
	frame_delay = length/frames
	
	set_delay.disconnect("value_changed", self, "_on_FrameDelay_value_changed")
	set_delay.value = frame_delay
	set_delay.connect("value_changed", self, "_on_FrameDelay_value_changed")

func _on_GifFrameCount_value_changed(value):
	frames = value
	frame_delay = length/frames
	
	set_delay.disconnect("value_changed", self, "_on_FrameDelay_value_changed")
	set_delay.value = frame_delay
	set_delay.connect("value_changed", self, "_on_FrameDelay_value_changed")
