shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform float rotation : hint_range(0.0, 6.28) = 0.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(0.0, 1.0);
uniform float light_border : hint_range(0.0, 1.0) = 0.4;
uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform float size = 50.0;
uniform float seed: hint_range(1, 10);
uniform float time = 0.0;

float rand(vec2 coord) {
	coord = mod(coord, vec2(1.0,1.0)*round(size));
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
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
		c *= circleNoise((uv * size) + (float(i+1)+10.) + vec2(time*time_speed,0.0));
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
	
	// check distance from center & distance to light
	float d_circle = distance(uv, vec2(0.5));
	float d_light = distance(uv , vec2(light_origin));
	// cut out a circle
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	uv = rotate(uv, rotation);
	uv = spherify(uv);
		
	float c1 = crater(uv );
	float c2 = crater(uv +(light_origin-0.5)*0.03);
	vec4 col = color1;
	
	a *= step(0.5, c1);
	if (c2<c1-(0.5-d_light)*2.0) {
		col = color2;
	}
	if (d_light > light_border) {
		col = color2;
	} 

	// cut out a circle
	a*= step(d_circle, 0.5);
	COLOR = vec4(col.rgb, a * col.a);
}
