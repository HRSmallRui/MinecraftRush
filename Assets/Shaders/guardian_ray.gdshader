shader_type canvas_item;

uniform float speed = 1.0;
uniform float white_threshold = 0.92;
uniform vec4 orange_color:source_color = vec4(1.0,0.55,0.0,1.0);
uniform float mix_power: hint_range(0.0, 1.0, 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 moving_uv = vec2(UV.x - (speed * TIME),UV.y);
	moving_uv = fract(moving_uv);
	vec4 in_tex = texture(TEXTURE,moving_uv);
	COLOR = vec4(in_tex.r,in_tex.g,in_tex.b,in_tex.a);
	if(!(COLOR.r > white_threshold && COLOR.g > white_threshold && COLOR.b > white_threshold))
	{
		//float brightness = COLOR.r + COLOR.g + COLOR.b / 3.0;
		vec4 target_color = vec4(orange_color.r,orange_color.g,orange_color.b,COLOR.a);
		COLOR = mix(COLOR,target_color,mix_power);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
