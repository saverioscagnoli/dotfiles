precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    
    // Blue light filter parameters
    float filterStrength = 0.7; // Adjust between 0.0 (no filter) and 1.0 (maximum filter)
    
    // Reduce blue channel more aggressively
    pixColor.b *= (1.0 - filterStrength * 0.6);
    
    // Balanced warm boost for yellow tone
    pixColor.r *= mix(1.0, 1.15, filterStrength); // Moderate red boost
    pixColor.g *= mix(1.0, 1.05, filterStrength); // Slight green boost
    
    // Apply a yellow color temperature shift
    vec3 yellowFilter = vec3(1.1, 0.8, 0.9); // Yellow without green tint
    pixColor.rgb = mix(pixColor.rgb, pixColor.rgb * yellowFilter, filterStrength * 0.5);
    
    // Preserve luminance to avoid darkening
    float originalLuma = dot(texture2D(tex, v_texcoord).rgb, vec3(0.299, 0.587, 0.114));
    float filteredLuma = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    if (filteredLuma > 0.0) {
        pixColor.rgb *= originalLuma / filteredLuma;
    }
    
    gl_FragColor = pixColor;
}