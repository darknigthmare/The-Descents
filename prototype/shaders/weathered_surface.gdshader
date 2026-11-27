shader_type spatial;

uniform vec4 surface_color : source_color = vec4(0.23,0.28,0.30,1.0);
uniform float surface_roughness = 0.88;
uniform float surface_metallic = 0.0;
uniform float grain_scale = 6.0;
uniform float panel_size = 3.0;
varying vec3 position_world;

float grain(vec3 p) {
	return fract(sin(dot(floor(p),vec3(127.1,311.7,74.7)))*43758.5453);
}

void vertex() {
	position_world = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}

void fragment() {
	float fine = grain(position_world*grain_scale);
	float broad = grain(position_world*0.5);
	vec3 grid = abs(fract(position_world/max(panel_size,0.1))-0.5);
	float seam = smoothstep(0.48,0.495,max(grid.x,grid.z));
	float damp = smoothstep(0.60,0.85,broad);
	ALBEDO = surface_color.rgb*(0.88+fine*0.15+broad*0.08)*(1.0-seam*0.13);
	ROUGHNESS = clamp(surface_roughness-damp*0.18,0.18,1.0);
	METALLIC = surface_metallic;
}
