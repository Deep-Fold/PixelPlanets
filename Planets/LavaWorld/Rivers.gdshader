shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform float rotation : hint_range(0.0, 6.28) = 0.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(-2.0, 3.0) = 0.2;
uniform float light_border_1 : hint_range(0.0, 1.0) = 0.4;
uniform float light_border_2 : hint_range(0.0, 1.0) = 0.5;
uniform float river_cutoff : hint_range(0.0, 1.0);

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform vec4 color3 : source_color;

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform float time = 0.0;


float rand(vec2 coord) {
	coord = mod(coord, vec2(2.0,1.0)*round(size));
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
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

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment() {
	// pixelize uv
	vec2 uv = floor(UV*pixels)/pixels;
	
	float d_light = distance(uv , light_origin);
	
	// cut out a circle
	float d_circle = distance(uv, vec2(0.5));
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	// give planet a tilt
	uv = rotate(uv, rotation);
	
	// map to sphere
	uv = spherify(uv);
	
	// some scrolling noise for landmasses
	float fbm1 = fbm(uv*size+vec2(time*time_speed,0.0));
	float river_fbm = fbm(uv + fbm1*2.5);
	
	// increase contrast on d_light
	d_light = pow(d_light, 2.0)*0.4;
	d_light -= d_light * river_fbm;
	
	river_fbm = step(river_cutoff, river_fbm);
	
	// apply colors
	vec4 col = color1;
	if (d_light > light_border_1) {
		col = color2;
	}
	if (d_light > light_border_2) {
		col = color3;
	}
	
	a *= step(river_cutoff, river_fbm);
	COLOR = vec4(col.rgb, a * col.a);
}
