// derrived from https://godotforums.org/d/41482-blur-shader-for-godot-4x/7
// so uhhh yeah didnt write it myself fully

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_lod = 4.0;

void fragment() {
    vec3 blurred = textureLod(screen_texture, SCREEN_UV, blur_lod).rgb;
    COLOR.rgb *= blurred - vec3(0.1,0.1,0.1); // lower the color so UI stays legible
}