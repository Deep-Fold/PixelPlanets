shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform float time_speed : hint_range(0.0, 1.0) = 0.05;
uniform float time;
uniform float rotation : hint_range(0.0, 6.28) = 0.0;
uniform sampler2D colorramp;
uniform bool should_dither = true;

uniform float seed: hint_range(1, 10);
uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float TILES : hint_range(0, 20, 1);


float rand(vec2 co) {
	co = mod(co, vec2(1.0,1.0)*round(size));
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}

vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
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

vec2 Hash2(vec2 p) {
	float r = 523.0*sin(dot(p, vec2(53.3158, 43.6143)));
	return vec2(fract(15.32354 * r), fract(17.25865 * r));
	
}

// Tileable cell noise by Dave_Hoskins from shadertoy: https://www.shadertoy.com/view/4djGRh
float Cells(in vec2 p, in float numCells) {
	p *= numCells;
	float d = 1.0e10;
	for (int xo = -1; xo <= 1; xo++)
	{
		for (int yo = -1; yo <= 1; yo++)
		{
			vec2 tp = floor(p) + vec2(float(xo), float(yo));
			tp = p - tp - Hash2(mod(tp, numCells / TILES));
			d = min(d, dot(tp, tp));
		}
	}
	return sqrt(d);
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

void fragment() {
	// pixelize uv
	vec2 pixelized = floor(UV*pixels)/pixels;
	
	// cut out a circle
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(distance(pixelized, vec2(0.5)), .49999);
	
	// use dither val later to mix between colors
	bool dith = dither(UV, pixelized);
	
	pixelized = rotate(pixelized, rotation);
	
	// spherify has to go after dither
	pixelized = spherify(pixelized);
	
	// use two different sized cells for some variation
	float n = Cells(pixelized - vec2(time * time_speed * 2.0, 0), 10);
	n *= Cells(pixelized - vec2(time * time_speed * 1.0, 0), 20);

	
	// adjust cell value to get better looking stuff
	n*= 2.;
	n = clamp(n, 0.0, 1.0);
	if (dith || !should_dither) { // here we dither
		n *= 1.3;
	}
	
	// constrain values 4 possibilities and then choose color based on those
	float interpolate = floor(n * 3.0) / 3.0;
	vec4 col = texture(colorramp, vec2(interpolate, 0.0));
	
	COLOR = vec4(col.rgb, a * col.a);
}