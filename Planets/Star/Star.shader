shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform vec4 color : hint_color;
uniform float time_scale : hint_range(0.0, 1.0) = 0.05;
uniform sampler2D colorramp;

uniform float seed: hint_range(1, 10);
uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float TILES : hint_range(0, 20, 1);


float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 * seed);
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

float fbm(vec2 coord){
	float value = 0.0;
	float scl = 0.5;

	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord) * scl;
		coord *= 2.0;
		scl *= 0.5;
	}
	return value;
}


vec2 Hash2(vec2 p, in float time) {
	float t = time*.3;
	return vec2(noise(p*vec2(.135+t, .2325-t)), noise(p*vec2(.3135+t, .5813-t)));
}

//------------------------------------------------------------------------
float Cells(in vec2 p, in float numCells, in float time) {
	p *= numCells;
	float d = 1.0e10;
	for (int xo = -1; xo <= 1; xo++)
	{
		for (int yo = -1; yo <= 1; yo++)
		{
			vec2 tp = floor(p) + vec2(float(xo), float(yo));
			tp = p - tp - Hash2(mod(tp, numCells / TILES), time);
			d = min(d, dot(tp, tp));
		}
	}
	return sqrt(d);
	//return 1.0 - d;// ...Bubbles.
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
	float time = TIME * time_scale;
	vec2 pixelized = floor(UV*pixels)/pixels;
	bool dith = dither(UV, pixelized);
	
	pixelized = spherify(pixelized);
	float n1 = fbm(pixelized * size + time);
//	n = fbm(pixelized + n * 5.0 + time);
//	n = pow(n + 0.2, 3.0);
	
	
	float n = Cells(pixelized - vec2(TIME * time_scale * 0.2, 0), 10, TIME * time_scale);
	n *= Cells(pixelized - vec2(TIME * time_scale * 0.2, 0), 15, TIME * time_scale);
	n*= 3.5;
	n = clamp(n, 0.0, 1.0);
	
	float a = step(distance(pixelized, vec2(0.5)), .5);
	
	if (dith) {
		n *= 1.3;
	}
	
	//n += distance(pixelized, vec2(0.5)) * 0.7;
	float interpolate = floor(n * 3.0) / 3.0;
	vec3 c = texture(colorramp, vec2(interpolate, 0.0)).rgb;
	
	COLOR = vec4(c, a * color.a);
}