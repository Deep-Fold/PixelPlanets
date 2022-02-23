shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,300) = 100.0;
uniform float rotation : hint_range(0.0, 6.28) = 0.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(-1.0, 1.0) = 0.2;
uniform float light_border_1 : hint_range(0.0, 1.0) = 0.52;
uniform float light_border_2 : hint_range(0.0, 1.0) = 0.62;
uniform float ring_width : hint_range(0.0, 0.15) = 0.1;
uniform float ring_perspective = 4.0;
uniform float scale_rel_to_planet = 6.0;

uniform sampler2D colorscheme;
uniform sampler2D dark_colorscheme;

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

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
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
	
	float light_d = distance(uv, light_origin);
	uv = rotate(uv, rotation);
	
	// center is used to determine ring position
	vec2 uv_center = uv - vec2(0.0, 0.5);
	
	// tilt ring
	uv_center *= vec2(1.0, ring_perspective);
	float center_d = distance(uv_center,vec2(0.5, 0.0));
	
	
	// cut out 2 circles of different sizes and only intersection of the 2.
	float ring = smoothstep(0.5-ring_width*2.0, 0.5-ring_width, center_d);
	ring *= smoothstep(center_d-ring_width, center_d, 0.4);
	
	// pretend like the ring goes behind the planet by removing it if it's in the upper half.
	if (uv.y < 0.5) {
		ring *= step(1.0/scale_rel_to_planet, distance(uv,vec2(0.5)));
	}
	
	// rotate material in the ring
	uv_center = rotate(uv_center+vec2(0, 0.5), time*time_speed);
	// some noise
	ring *= fbm(uv_center*size);
	
	// apply some colors based on final value
	float posterized = floor((ring+pow(light_d, 2.0)*2.0)*4.0)/4.0;
	vec4 col;
	if (posterized <= 1.0) {
		col = texture(colorscheme, vec2(posterized, uv.y));
	} else {
		col = texture(dark_colorscheme, vec2(posterized-1.0, uv.y));
	}
	float ring_a = step(0.28, ring);
	COLOR = vec4(col.rgb, ring_a * col.a);
}
