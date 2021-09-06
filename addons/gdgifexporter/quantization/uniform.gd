extends Reference


var converter = preload('../converter.gd').new()
var transparency := false

func how_many_divisions(colors_count: int) -> int:
	return int(ceil( pow(colors_count, 1.0 / 4.0) ))


func generate_colors(colors_count: int) -> Array:
	var divisions_count: int = how_many_divisions(colors_count)
	var colors: Array = []

	for a in range(divisions_count):
		for b in range(divisions_count):
			for g in range(divisions_count):
				for r in range(divisions_count):
					colors.append([Vector3(
							(255.0 / divisions_count) * r,
							(255.0 / divisions_count) * g,
							(255.0 / divisions_count) * b),
							(255.0 / divisions_count) * a])

	return colors

func find_nearest_color(palette_color: Vector3, image_data: PoolByteArray) -> Array:
	var nearest_color = null
	var nearest_alpha = null
	for i in range(0, image_data.size(), 4):
			var color = Vector3(image_data[i], image_data[i + 1], image_data[i + 2])
			# detect transparency
			if image_data[3] == 0:
				transparency = true
			if (nearest_color == null) or (palette_color.distance_squared_to(color) < palette_color.distance_squared_to(nearest_color)):
				nearest_color = color
				nearest_alpha = image_data[i + 3]
	return [nearest_color, nearest_alpha]

# moves every color from palette colors to the nearest found color in image
func enhance_colors(image: Image, palette_colors: Array) -> Array:
	var data := image.get_data()

	for i in range(palette_colors.size()):
		var nearest_color := find_nearest_color(palette_colors[i][0], data)
		palette_colors[i] = nearest_color

	return palette_colors

func to_color_array(colors: Array) -> Array:
	var result := []
	for v in colors:
		result.append([v[0].x, v[0].y, v[0].z])
	return result

# quantizes to gif ready codes
func quantize(image: Image) -> Array:
	image.lock()

	var colors: Array = generate_colors(256)
	var tmp_image: Image = Image.new()
	tmp_image.copy_from(image)
	tmp_image.resize(32, 32)
	tmp_image.lock()
	colors = enhance_colors(tmp_image, colors)
	tmp_image.unlock()

	image.unlock()
	colors = to_color_array(colors)
	
	var data: PoolByteArray = converter.get_similar_indexed_datas(image, colors)
	
	return [data, colors, transparency]
