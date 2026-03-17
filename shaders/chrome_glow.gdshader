// Copyright: UNCG Game Development Club Long-term Project
// Contributers: Dr. Richard B. Johnson
shader_type canvas_item;

uniform vec4 chrome_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float hit_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float speed : hint_range(0.0, 10.0) = 5.0;

void fragment() {
    // 1. Explicitly grab the texture pixel
    vec4 tex = texture(TEXTURE, UV);
    
    // 2. Create a 'Chrome' factor
    // We'll use a mix of the edge and a moving shine so it doesn't look flat
    float shine = sin(UV.y * 10.0 + UV.x * 10.0 + TIME * speed) * 0.5 + 0.5;
    
    // 3. Define the Chrome Color Surge
    // This combines the uniform color with the shine we just made
    vec3 chrome_rgb = mix(chrome_color.rgb, vec3(1.0), shine);
    
    // 4. THE COMPOSITION (The fix for the silhouette)
    // We take the original texture and MIX it with the chrome based on hit_intensity
    // This ensures that when intensity is 0, you see 100% of the original sprite.
    vec3 final_color = mix(tex.rgb, chrome_rgb, hit_intensity);
    
    // 5. Brighten the edges specifically to give it that "Hard" metallic feel
    float edge = fwidth(tex.a);
    final_color += (chrome_color.rgb * edge * hit_intensity * 2.0);
    
    // 6. Output - IMPORTANT: Multiply by tex.a to keep the shape
    COLOR = vec4(final_color, tex.a);
}
