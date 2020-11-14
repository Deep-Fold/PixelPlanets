shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(0.0, 1.0) = 0.2;
uniform float dither_size : hint_range(0.0, 10.0) = 2.0;
uniform float light_border_1 : hint_range(0.0, 1.0) = 0.4;
uniform float light_border_2 : hint_range(0.0, 1.0) = 0.5;
uniform float river_cutoff : hint_range(0.0, 1.0);

uniform vec4 col1 : hint_color;
uniform vec4 col2 : hint_color;
uniform vec4 col3 : hint_color;
uniform vec4 col4 : hint_color;
uniform vec4 river_col : hint_color;
uniform vec4 river_col_dark : hint_color;

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);



float rand(vec2 coord) {
	// land has to be tiled (or the contintents on this planet have to be changing very fast)
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

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

void fragment() {
	// pixelize uv
	vec2 uv = floor(UV*pixels)/pixels;
	
	float d_light = distance(uv , light_origin);
	
	// give planet a tilt
	uv = rotate(uv, 0.2);
//
//	// map to sphere
	uv = spherify(uv);
	
	// some scrolling noise for landmasses
	vec2 base_fbm_uv = (uv)*size+vec2(TIME*time_speed,0.0);
	
	// use multiple fbm's at different places so we can determine what color land gets
	float fbm1 = fbm(base_fbm_uv);
	float fbm2 = fbm(base_fbm_uv - light_origin*fbm1);
	float fbm3 = fbm(base_fbm_uv - light_origin*1.5*fbm1);
	float fbm4 = fbm(base_fbm_uv - light_origin*2.0*fbm1);
	
	float river_fbm = fbm(base_fbm_uv+fbm1*6.0);
	river_fbm = step(river_cutoff, river_fbm);
	
	// size of edge in which colors should be dithered
	float dither_border = (1.0/pixels)*dither_size;
	// lots of magic numbers here
	// you can mess with them, it changes the color distribution
	if (d_light < light_border_1) {
		fbm4 *= 0.9;
	}
	if (d_light > light_border_1) {
		fbm2 *= 1.05;
		fbm3 *= 1.05;
		fbm4 *= 1.05;
	} 
	if (d_light > light_border_2) {
		fbm2 *= 1.3;
		fbm3 *= 1.4;
		fbm4 *= 1.8;
		if (d_light < light_border_2 +dither_border && dither(uv, uv)) {
			fbm4 *= 0.5;
		}
	} 
//	if (d_light < light_border_1) {
//		fbm4 *= 0.9;
//	}
	
	
	// increase contrast on d_light
	d_light = pow(d_light, 2.0)*0.4;
	vec3 col = col4.rgb;
	if (fbm4 + d_light < fbm1*1.5) {
		col = col3.rgb;
	}
	if (fbm3 + d_light < fbm1*1.0) {
		col = col2.rgb;
	}
	if (fbm2 + d_light < fbm1) {
		col = col1.rgb;
	}
	if (river_fbm < fbm1*0.5) {
		col = river_col_dark.rgb;
		if (fbm4 + d_light < fbm1*1.5) {
			col = river_col.rgb;
		}
	}
	
	COLOR = vec4(col, step(distance(vec2(0.5), uv), 0.5));
}
