shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform float rotation : hint_range(0.0, 6.28) = 1.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(0.0, 1.0) = 0.2;
uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform vec4 color3 : source_color;
uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform bool should_dither = true;

float rand(vec2 coord) {
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

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return m = smoothstep(r-.10*r,r,m);
}

float crater(vec2 uv) {
	float c = 1.0;
	for (int i = 0; i < 2; i++) {
		c *= circleNoise((uv * size) + (float(i+1)+10.));
	}
	return 1.0 - c;
}

void fragment() {
	//pixelize uv
	vec2 uv = floor(UV*pixels)/pixels;
	
	// we use this val later to interpolate between shades
	bool dith = dither(uv, UV);
	
	// distance from center
	float d = distance(uv, vec2(0.5));
	
	// optional rotation, do this after the dither or the dither will look very messed up
	uv = rotate(uv, rotation);
	
	// two noise values with one slightly offset according to light source, to create shadows later
	float n = fbm(uv * size);
	float n2 = fbm(uv * size + (rotate(light_origin, rotation)-0.5) * 0.5);
	
	// step noise values to determine where the edge of the asteroid is
	// step cutoff value depends on distance from center
	float n_step = step(0.2, n - d);
	float n2_step = step(0.2, n2 - d);
	
	// with this val we can determine where the shadows should be
	float noise_rel = (n2_step + n2) - (n_step + n);
	
	// two crater values, again one extra for the shadows
	float c1 = crater(uv );
	float c2 = crater(uv + (light_origin-0.5)*0.03);

	// now we just assign colors depending on noise values and crater values
	// base
	vec4 col = color2;
	
	// noise
	if (noise_rel < -0.06 || (noise_rel < -0.04 && (dith || !should_dither))) {
		col = color1;
	}
	if (noise_rel > 0.05 || (noise_rel > 0.03 && (dith || !should_dither))) {
		col = color3;
	}
	
	// crater
	if (c1 > 0.4)  {
		col = color2;
	}
	if (c2<c1) {
		col = color3;
	}
	
	COLOR = vec4(col.rgb, n_step * col.a);
}
