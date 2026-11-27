shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 veil_tint : source_color = vec4(0.32, 0.43, 0.48, 1.0);
uniform float clock = 0.0;
uniform float opacity = 0.14;
uniform float sector = 0.0;

void fragment() {
    float broad = 0.5 + 0.5 * sin(UV.x * 19.0 + sector * 2.7);
    float narrow = 0.5 + 0.5 * sin(UV.x * 73.0 + sin(UV.y * 9.0 + sector));
    float drift = 0.86 + 0.14 * sin(UV.y * 12.0 + clock * 0.07 + sector);
    float sides = smoothstep(0.0, 0.15, UV.x) * (1.0 - smoothstep(0.85, 1.0, UV.x));
    float ends = smoothstep(0.0, 0.22, UV.y) * (1.0 - smoothstep(0.72, 1.0, UV.y));
    ALBEDO = veil_tint.rgb;
    ALPHA = opacity * sides * ends * (0.25 + broad * 0.55 + narrow * 0.20) * drift;
}
