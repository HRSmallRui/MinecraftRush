shader_type canvas_item;

// 色相偏移量（范围 0.0 ~ 1.0，对应 0° ~ 360° 的色相旋转）
// 0.0 = 原色相，0.33 ≈ 120°，0.66 ≈ 240°，1.0 = 回到原色相
uniform float hue_shift : hint_range(0.0, 1.0) = 0.0;

// 将 RGB 颜色转换为 HSV 颜色空间
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10; // 避免除以 0
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// 将 HSV 颜色转换回 RGB 颜色空间
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.x + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // 获取原始纹理颜色（包含 alpha 通道）
    vec4 original_color = texture(TEXTURE, UV);

    // 只对 RGB 通道进行色相调整，保留 alpha
    vec3 hsv_color = rgb2hsv(original_color.rgb);

    // 调整色相（取模确保在 0~1 范围内）
    hsv_color.x = mod(hsv_color.x + hue_shift, 1.0);

    // 转换回 RGB 并保留原 alpha
    vec3 adjusted_rgb = hsv2rgb(hsv_color);
    COLOR = vec4(adjusted_rgb, original_color.a);
}