shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
	vec3 col = (1.0 - textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb) * vec3(5,5,5);
	col = clamp(col, 0.0, 1.0); // om te voorkome da t over brightness wordt
	COLOR.rgb = col;
	COLOR.a = texture(TEXTURE , UV).a;
}