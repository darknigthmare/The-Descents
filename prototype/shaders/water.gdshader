shader_type spatial;
render_mode specular_schlick_ggx, cull_disabled;

uniform vec4 deep_color : source_color = vec4(0.018, 0.080, 0.105, 1.0);
uniform vec4 crest_color : source_color = vec4(0.12, 0.25, 0.27, 1.0);
// Advanced only by the world's explicit presentation clock; pause and seek safe.
uniform float clock = 0.0;
varying vec3 local_pos;

void vertex() {
    local_pos = VERTEX;
    float swell_a = VERTEX.x * 0.045 + VERTEX.z * 0.017 + clock * 0.53;
    float swell_b = VERTEX.z * 0.071 - VERTEX.x * 0.014 - clock * 0.34;
    float swell_c = (VERTEX.x - VERTEX.z) * 0.026 + clock * 0.23;
    VERTEX.y += sin(swell_a) * 0.72 + sin(swell_b) * 0.44 + sin(swell_c) * 0.35;
    float slope_x = cos(swell_a) * 0.0324 - cos(swell_b) * 0.00616 + cos(swell_c) * 0.0091;
    float slope_z = cos(swell_a) * 0.01224 + cos(swell_b) * 0.03124 - cos(swell_c) * 0.0091;
    NORMAL = normalize(vec3(-slope_x, 1.0, -slope_z));
}

void fragment() {
    float ripples_a = sin(local_pos.x * 0.71 + local_pos.z * 0.23 + clock * 1.1);
    float ripples_b = sin(local_pos.z * 0.93 - local_pos.x * 0.12 - clock * 0.85);
    float broad = 0.5 + 0.5 * sin(local_pos.x * 0.015 + local_pos.z * 0.022);
    float ridge = pow(max(0.0, sin(local_pos.x * 0.12 + local_pos.z * 0.08 + clock * 0.35)), 18.0);
    float broken_foam = ridge * smoothstep(0.15, 0.8, ripples_a * ripples_b) * 0.17;
    ALBEDO = mix(deep_color.rgb, crest_color.rgb, 0.08 + broad * 0.10 + broken_foam);
    NORMAL_MAP = normalize(vec3(ripples_a * 0.16, ripples_b * 0.13, 1.0)) * 0.5 + 0.5;
    NORMAL_MAP_DEPTH = 0.65;
    ROUGHNESS = 0.24 + broken_foam * 0.25;
    METALLIC = 0.20;
    SPECULAR = 0.68;
}
