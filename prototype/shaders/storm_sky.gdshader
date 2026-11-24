shader_type sky;
render_mode disable_fog;

// The horizon shares its colour with Environment fog. It remains continuous
// below the visible sea horizon when distant water reaches the camera far plane.
uniform vec3 horizon_tint : source_color = vec3(0.235294, 0.349020, 0.396078);
uniform vec3 zenith_tint : source_color = vec3(0.039216, 0.086275, 0.137255);
uniform vec3 cloud_shadow : source_color = vec3(0.070588, 0.117647, 0.149020);
uniform vec3 cloud_edge : source_color = vec3(0.270588, 0.356863, 0.396078);

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise21(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash21(cell), hash21(cell + vec2(1.0, 0.0)), f.x),
        mix(hash21(cell + vec2(0.0, 1.0)), hash21(cell + vec2(1.0, 1.0)), f.x), f.y);
}

float cloud_bank(vec2 p) {
    float value = noise21(p) * 0.56;
    p = mat2(vec2(1.65, 1.12), vec2(-1.12, 1.65)) * p;
    value += noise21(p + vec2(7.1, 3.8)) * 0.28;
    value += noise21(p * 2.03 + vec2(3.7, 9.2)) * 0.16;
    return value;
}

void sky() {
    float elevation = max(EYEDIR.y, 0.0);
    vec3 base = mix(horizon_tint, zenith_tint, pow(elevation, 0.48));
    // A broad shelf and a finer upper deck have different scales. Everything
    // is static: no per-frame radiance rebuild or unpaused shader animation.
    vec2 plane = EYEDIR.xz / (elevation + 0.18);
    float shelf = cloud_bank(plane * vec2(0.78, 1.22) + vec2(2.1, -4.7));
    float upper = cloud_bank(plane * 2.6 + vec2(-3.2, 6.1));
    float density = smoothstep(0.31, 0.69, shelf * 0.72 + upper * 0.28);
    float lip = smoothstep(0.44, 0.57, upper) * (1.0 - smoothstep(0.57, 0.73, upper));
    vec3 cloud = mix(cloud_shadow, cloud_edge, 0.18 + lip * 0.48);
    vec3 layered = mix(base, cloud, density * 0.88);
    // A low band of sea haze absorbs the finite water edge at all azimuths.
    float above_haze = smoothstep(0.015, 0.17, elevation);
    COLOR = mix(horizon_tint, layered, above_haze);
}
