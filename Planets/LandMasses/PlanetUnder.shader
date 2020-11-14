shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(0.0, 1.0) = 0.2;
uniform float dither_size : hint_range(0.0, 10.0) = 2.0;
uniform float light_border_1 : hint_range(0.0, 1.0) = 0.4;
uniform float light_border_2 : hint_range(0.0, 1.0) = 0.6;
uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform vec4 color3 : hint_color;
uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);

float rand(vec2 coord) {
	// land has to be tiled
	// tiling only works for integer values, thus the rounding
	// it would probably be better to only allow integer sizes
	// multiply by vec2(2,1) to simulate planet having another side
	coord = mod(coord, vec2(2.0,1.0)*round(size));
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 43758.5453 * seed);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

void fragment() {
	//pixelize uv
	vec2 uv = floor(UV*pixels)/pixels;
	// check distance from center & distance to light
	float d_circle = distance(uv, vec2(0.5));
	float d_light = distance(uv , vec2(light_origin));
	
	// cut out a circle
	float a = step(d_circle, 0.5);
	
	// get a noise value with light distance added
	d_light += fbm(uv*size+vec2(TIME*time_speed, 0.0))*0.3; // change the magic 0.3 here for different light strengths
	
	// size of edge in which colors should be dithered
	float dither_border = (1.0/pixels)*dither_size;

	// now we can assign colors based on distance to light origin
	vec3 col = color1.rgb;
	if (d_light > light_border_1) {
		col = color2.rgb;
		if (d_light < light_border_1 + dither_border && dither(uv, UV)) {
			col = color1.rgb;
		}
	}
	if (d_light > light_border_2) {
		col = color3.rgb;
		if (d_light < light_border_2 + dither_border && dither(uv, UV)) {
			col = color2.rgb;
		}
	}
	
	COLOR = vec4(col, a);
}
