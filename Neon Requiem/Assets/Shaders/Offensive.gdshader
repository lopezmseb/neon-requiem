shader_type canvas_item;

// Default line color (Pink)
uniform vec4 line_color : source_color = vec4(1, 0.42, 0.69, 1);

// TODO: Add pulsating effect?
uniform float min_thickness : hint_range(0, 1) = 0.0;
uniform float max_thickness : hint_range(0, 1) = 1.0;
uniform float line_thickness : hint_range(0, 10) = 1.0;

// Colorblind mode uniform (0: None, 1: Deuteranopia, 2: Protanopia, 3: Tritanopia)
uniform int colourBlindMode : hint_range(0, 3);

// Colorblind-friendly color adjustments
vec4 get_colorblind_friendly_color(vec4 color) {
    if (colourBlindMode == 1) {  // Deuteranopia (Red-Green Blindness)
        return vec4(1.0, 0.5, 0.8, color.a);  // Shift toward pinkish
    }
    if (colourBlindMode == 2) {  // Protanopia (Red-Green Blindness)
        return vec4(0.9, 0.4, 0.7, color.a);  // Slightly reduce red
    }
    if (colourBlindMode == 3) {  // Tritanopia (Blue-Yellow Blindness)
        return vec4(0.8, 0.4, 1.0, color.a);  // More purple-pink
    }
    return color; // Default color (None)
}

// Offsets for outline detection
const vec2 OFFSETS[8] = {
    vec2(-1, -1), vec2(-1, 0), vec2(-1, 1),
    vec2(0, -1), vec2(0, 1),
    vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    float outline = 0.0;

    // Calculate outline
    for (int i = 0; i < OFFSETS.length(); i++) {
        outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
    }
    
    outline = min(outline, 1.0);
    
    vec4 color = texture(TEXTURE, UV);
    vec4 adjusted_line_color = get_colorblind_friendly_color(line_color);

    COLOR = mix(color, adjusted_line_color, outline - color.a);
}
