shader_type canvas_item;

uniform float mix_stength: hint_range(0.0, 1.0, 0.01);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = mix(COLOR,vec4(1.0,1.0,1.0,COLOR.a),mix_stength);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
