shader_type canvas_item;

// 可调节参数
uniform float heat_strength: hint_range(0.0, 1.0, 0.01) = 0.02;
uniform float heat_speed = 1.5;
uniform float brightness_offset = 0.1;

uniform sampler2D noise_texture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture,filter_linear_mipmap;

void fragment() {
   vec2 moving_uv = vec2(UV.x ,UV.y + (heat_speed * TIME));
	moving_uv = fract(moving_uv);
	vec4 in_tex = texture(noise_texture,moving_uv);
	COLOR = vec4(in_tex.r,in_tex.g,in_tex.b,in_tex.a);
	float hint_strength = COLOR.r;
	COLOR = texture(SCREEN_TEXTURE,SCREEN_UV,hint_strength * heat_strength);

}