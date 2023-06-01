shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,300);
uniform vec4 color : source_color;
uniform float time_speed : hint_range(0.0, 1.0) = 0.05;
uniform float time = 0.0;
uniform float rotation : hint_range(0.0, 6.28) = 0.0;


uniform float seed: hint_range(1, 10);
uniform float circle_amount : hint_range(2.0, 30.0) = 5.0;
uniform float circle_size : hint_range(0.0, 1.0) = 1.0;

uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);


float rand(vec2 co){
	co = mod(co, vec2(1.0,1.0)*round(size));
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}


vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
}

float circle(vec2 uv) {
	float invert = 1.0 / circle_amount;
	
	if (mod(uv.y, invert*2.0) < invert) {
		uv.x += invert*0.5;
	}
	vec2 rand_co = floor(uv*circle_amount)/circle_amount;
	uv = mod(uv, invert)*circle_amount;
	
	float r = rand(rand_co);
	r = clamp(r, invert, 1.0 - invert);
	float circle = distance(uv, vec2(r));
	return smoothstep(circle, circle+0.5, invert * circle_size * rand(rand_co*1.5));
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

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

void fragment() {
	vec2 pixelized = floor(UV*pixels)/pixels;

	vec2 uv = rotate(pixelized, rotation);

	// angle from centered uv's
	float angle = atan(uv.x - 0.5, uv.y - 0.5);
	float d = distance(pixelized, vec2(0.5));
	
	
	float c = 0.0;
	for(int i = 0; i < 15; i++) {
		float r = rand(vec2(float(i)));
		vec2 circleUV = vec2(d, angle);
		c += circle(circleUV*size -time * time_speed - (1.0/d) * 0.1 + r);
	}
	
	c *= 0.37 - d;
	c = step(0.07, c - d);
	
	COLOR = vec4(color.rgb, c * color.a);
}