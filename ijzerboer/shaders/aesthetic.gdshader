shader_type spatial;
render_mode vertex_lighting;

uniform float scale = 0.04;
uniform sampler2D albedo_texture : source_color;

void vertex() {
    vec3 v = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    v = floor(v / scale) * scale;
    VERTEX = (inverse(MODELVIEW_MATRIX) * vec4(v, 1.0)).xyz;
}

void fragment() {
    ALBEDO = texture(albedo_texture, UV).rgb; // waarom is het ZO fucking annoying om gwn een FUCKING TEXTURE TE HOUDEN SCREW YOU GODOT SHADER SYETEM CURSE YOU
}
