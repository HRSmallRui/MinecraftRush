shader_type canvas_item;

uniform float speed = 1.0;
uniform vec4 modulate: source_color;
uniform float whole_alpha = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 moving_uv = vec2(UV.x - (speed * TIME),UV.y);
	moving_uv = fract(moving_uv);
	vec4 in_tex = texture(TEXTURE,moving_uv);
	COLOR = vec4(modulate.r,modulate.g,modulate.b,whole_alpha * in_tex.a);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
