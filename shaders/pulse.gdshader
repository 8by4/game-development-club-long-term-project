// Copyright: UNCG Game Development Club Long-term Project
// Contributers: Dr. Richard B. Johnson
shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1, 0, 0, 1);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // Mix the original color with the flash color based on intensity
    COLOR = vec4(mix(tex_color.rgb, flash_color.rgb, intensity), tex_color.a);
}

/*
// This allows the GDScript to change the "redness"
//uniform float red_amount : hint_range(0.0, 1.0) = 0.0;
void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // We mix the original color with a red version based on red_amount
    vec3 red_tint = vec3(1.0, 0.0, 0.0);
    COLOR.rgb = mix(tex_color.rgb, red_tint, red_amount * tex_color.a);
    COLOR.a = tex_color.a;
}
*/
