shader_type canvas_item;
uniform float shade : hint_range(0.0, 1.0) = 0.4;
uniform float edge_strength : hint_range(0.0, 1.0) = 0.55;
uniform float grain_strength : hint_range(0.0, 0.1) = 0.018;
void fragment() {
	vec2 q = UV - vec2(0.5);
	float edge = smoothstep(0.25, 0.76, length(q * vec2(1.15, 0.9)));
	float grain = fract(sin(dot(UV * 980.0,vec2(12.9898,78.233))) * 43758.5453) * grain_strength;
	COLOR = vec4(vec3(0.012,0.025,0.032) + grain, clamp(shade + edge * edge_strength,0.0,0.96));
}
