shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(0.0, 1.0) = 0.2;
uniform float light_border : hint_range(0.0, 1.0) = 0.4;
uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform float size = 50.0;
uniform float seed: hint_range(1, 10);

vec2 hash( float n ) {
    float sn = sin(n);
    return fract(vec2(sn,sn*42125.13)*seed);
}
// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
	float uv_y = floor(uv.y);
	uv.x += uv_y*.31;
	vec2 f = fract(uv);
	vec2 h = hash(floor(uv.x)*uv_y);
	float m = (length(f-0.25-(h.x*0.5)));
	float r = h.y*0.25;
	return m = smoothstep(r-.10*r,r,m);
}

float crater(vec2 uv) {
	float c = 1.0;
	for (int i = 0; i < 2; i++) {
		c *= circleNoise((uv * size) + (float(i+1)*10.));
	}
	return 1.0 - c;
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
	//pixelize uv
	vec2 uv = floor(UV*pixels)/pixels;
	
	uv = rotate(uv, 0.4);
	
	// check distance from center & distance to light
	float d_circle = distance(uv, vec2(0.5));
	float d_light = distance(uv , vec2(light_origin));
	
	uv = spherify(uv);
		
	float c1 = crater(uv + vec2(TIME*time_speed, 0.0));
	float c2 = crater(uv + vec2(TIME*time_speed, 0.0) +(light_origin-0.5)*0.03);
	vec3 col = color1.rgb;
	
	float a = step(0.5, c1);
	if (c2<c1-(0.5-d_light)*2.0) {
		col = color2.rgb;
	}
	if (d_light > light_border) {
		col = color2.rgb;
	} 

	// cut out a circle
	a*= step(d_circle, 0.5);
	COLOR = vec4(col, a);
}
