shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE,SCREEN_UV);
	COLOR = vec4(1.0 -color.r, 1.0 -color.g, 1.0 - color.b, COLOR.a);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
