shader_type spatial;
render_mode specular_schlick_ggx, cull_disabled;

uniform vec4 deep_color : source_color = vec4(0.018, 0.080, 0.105, 1.0);
uniform vec4 crest_color : source_color = vec4(0.12, 0.25, 0.27, 1.0);
varying vec3 local_pos;

void vertex() {
    local_pos = VERTEX;
    float wave = sin(VERTEX.x * 0.045 + TIME * 0.53) * 0.85;
    wave += sin(VERTEX.z * 0.071 - TIME * 0.34) * 0.52;
    VERTEX.y += wave;
    NORMAL = normalize(vec3(-cos(VERTEX.x * 0.045 + TIME * 0.53) * 0.038, 1.0,
                            -cos(VERTEX.z * 0.071 - TIME * 0.34) * 0.037));
}

void fragment() {
    float ripple = sin(local_pos.x * 0.55 + TIME * 0.6) * sin(local_pos.z * 0.63 - TIME * 0.45);
    float streak = pow(max(0.0, sin(local_pos.x * 0.12 + local_pos.z * 0.08 + TIME * 0.35)), 14.0);
    ALBEDO = mix(deep_color.rgb, crest_color.rgb, 0.10 + 0.09 * ripple + 0.2 * streak);
    ROUGHNESS = 0.23;
    METALLIC = 0.35;
    SPECULAR = 0.75;
}
