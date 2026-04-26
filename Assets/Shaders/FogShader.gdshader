shader_type canvas_item;

uniform float speed = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 moving_uv = vec2(UV.x - (speed * TIME),UV.y);
	moving_uv = fract(moving_uv);
	vec4 in_tex = texture(TEXTURE,moving_uv);
	float right_a;
	if(COLOR.a > in_tex.a)
	{
		right_a = in_tex.a;
	}else
	{
		right_a = COLOR.a;
	}
	COLOR = vec4(COLOR.r,COLOR.g,COLOR.b,right_a);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
