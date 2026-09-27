vec4 animation(vec2 uv) {
    vec4 color = umbriel_sample(uv);

    float progress = umbriel_clamped_progress;
    float visible = umbriel_direction > 0.0 ? progress : 1.0 - progress;

    float height = max(umbriel_size.y, 1.0);
    float aspect = umbriel_size.x / height;
    vec2 aspect_uv = uv;
    aspect_uv.x *= aspect;

    float distance_from_top_left = length(aspect_uv);
    float max_radius = length(vec2(aspect, 1.0));
    float current_radius = max_radius * visible;
    float edge_softness = 2.0 / height;

    float iris = 1.0 - smoothstep(
        current_radius - edge_softness,
        current_radius + edge_softness,
        distance_from_top_left
    );

    // Make the exact endpoints fully transparent or unchanged. In particular,
    // this avoids clipping the bottom-right corner on the final opening frame.
    iris = visible <= 0.0 ? 0.0 : iris;
    iris = visible >= 1.0 ? 1.0 : iris;

    // Apply a subtle fade while preserving premultiplied RGBA.
    float opacity = mix(0.9, 1.0, visible);
    return color * (iris * opacity);
}
