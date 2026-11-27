shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;

uniform float strength = 0.0;
uniform float clock = 0.0;

void fragment() {
	vec2 p = (UV-vec2(0.5))*2.0;
	float r = length(p);
	float angle = atan(p.y,p.x);
	float spiral = 0.5+0.5*sin(r*38.0-angle*4.0-clock*3.0);
	float wisps = pow(spiral,5.0)*(0.6+0.4*sin(angle*11.0+r*20.0));
	float fade = smoothstep(0.16,0.32,r)*(1.0-smoothstep(0.65,0.98,r));
	ALBEDO = vec3(0.65,0.74,0.75);
	ALPHA = max(0.0,wisps*fade)*strength*0.11;
}
