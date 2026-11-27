shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 rain_tint : source_color = vec4(0.54, 0.67, 0.72, 1.0);
uniform float clock = 0.0;
uniform float fall_speed = 18.0;
uniform float volume_height = 240.0;
uniform float opacity = 0.24;
varying float drop_alpha;

void vertex() {
    // Instance centres stay outside both tower envelopes. Wind inclines only
    // the short streak; it cannot blow a column through an interior room.
    VERTEX.x += VERTEX.y * 0.16;
    VERTEX.y += mod(INSTANCE_CUSTOM.x * volume_height - clock * fall_speed, volume_height);
    drop_alpha = 0.48 + INSTANCE_CUSTOM.y * 0.52;
}

void fragment() {
    float tip = smoothstep(0.0, 0.16, UV.y) * (1.0 - smoothstep(0.84, 1.0, UV.y));
    ALBEDO = rain_tint.rgb;
    ALPHA = opacity * drop_alpha * tip;
}
