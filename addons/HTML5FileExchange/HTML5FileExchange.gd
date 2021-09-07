extends Node

signal InFocus

func _ready():
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		_define_js()


func _notification(notification:int) -> void:
	if notification == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		emit_signal("InFocus")

func _define_js()->void:
	#Define JS script
	JavaScript.eval("""
	var fileData;
	var fileType;
	var fileName;
	var canceled;
	function upload() {
		canceled = true;
		var input = document.createElement('INPUT'); 
		input.setAttribute("type", "file");
		input.setAttribute("accept", "image/png, image/jpeg, image/webp");
		input.click();
		input.addEventListener('change', event => {
			if (event.target.files.length > 0){
				canceled = false;}
			var file = event.target.files[0];
			var reader = new FileReader();
			fileType = file.type;
			fileName = file.name;
			reader.readAsArrayBuffer(file);
			reader.onloadend = function (evt) {
				if (evt.target.readyState == FileReader.DONE) {
					fileData = evt.target.result;
				}
			}
		  });
	}
	function download(fileName, byte) {
		var buffer = Uint8Array.from(byte);
		var blob = new Blob([buffer], { type: 'image/png'});
		var link = document.createElement('a');
		link.href = window.URL.createObjectURL(blob);
		link.download = fileName;
		link.click();
	};
	function downloadGif(fileName, byte) {
		var buffer = Uint8Array.from(byte);
		var blob = new Blob([buffer], { type: 'image/gif'});
		var link = document.createElement('a');
		link.href = window.URL.createObjectURL(blob);
		link.download = fileName;
		link.click();
	};
	""", true)
	
	
func load_image()->Image:
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		return
		
	#Execute js function
	JavaScript.eval("upload();", true)	#opens promt for choosing file
	
	#label.text = "Wait for focus"
	yield(self, "InFocus")	#wait until js promt is closed
	
	#label.text = "Timer on for loading"
	yield(get_tree().create_timer(0.1), "timeout")	#give some time for async js data load
	
	if JavaScript.eval("canceled;", true):	# if File Dialog closed w/o file
		#label.text = "Canceled prompt"
		return
	
	# use data from png data
	#label.text = "Load image"
	var imageData
	while true:
		imageData = JavaScript.eval("fileData;", true)
		if imageData != null:
			break
		#label.text = "No image yet"
		yield(get_tree().create_timer(1.0), "timeout")	#need more time to load data
	
	var imageType = JavaScript.eval("fileType;", true)
	var imageName = JavaScript.eval("fileName;", true)
	
	var image = Image.new()
	var image_error
	match imageType:
		"image/png":
			image_error = image.load_png_from_buffer(imageData)
		"image/jpeg":
			image_error = image.load_jpg_from_buffer(imageData)
		"image/webp":
			image_error = image.load_webp_from_buffer(imageData)
		var invalidType:
			#label.text = "Unsupported file format - %s." % invalidType
			return
	if image_error:
		#label.text = "An error occurred while trying to display the image."
		return
	else:
		return image
		# Display texture
		var tex = ImageTexture.new()
		tex.create_from_image(image, 0) # Flag = 0 or else export is fucked!
		Sprite.texture = tex
		#loadedImage = image # Keep Image for later, just in case...
		#loadedImageName = imageName
		#label.text = "Image %s loaded as %s." % [imageName, imageType]
		return
	#label.text = "Something went wrong"


func save_image(image:Image, fileName:String = "export")->void:
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		return
		
	image.clear_mipmaps()
	if image.save_png("user://export_temp.png"):
		#label.text = "Error saving temp file"
		return
	var file:File = File.new()
	if file.open("user://export_temp.png", File.READ):
		#label.text = "Error opening file"
		return
	var pngData = Array(file.get_buffer(file.get_len()))	#read data as PoolByteArray and convert it to Array for JS
	file.close()
	var dir = Directory.new()
	dir.remove("user://export_temp.png")
	JavaScript.eval("download('%s', %s);" % [fileName, str(pngData)], true)
	#label.text = "Saving DONE"
