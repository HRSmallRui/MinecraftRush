shader_type canvas_item;

uniform float effect_strength: hint_range(0.0, 1.0, 0.1);
uniform float extra_white_strength;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float gray = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	gray += extra_white_strength;
	vec4 new_color = vec4(gray,gray,gray,COLOR.a);
	COLOR = mix(COLOR,new_color,effect_strength);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
