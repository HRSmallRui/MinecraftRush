shader_type canvas_item;

// 核心开关：0=完全关闭，1=效果拉满（控制所有效果强度）
uniform float effect_master : hint_range(0.0, 1.0, 0.01) = 1.0;
// 色散强度（基础值，最终受 master 控制）
uniform float dispersion_strength : hint_range(0.0, 0.05, 0.001) = 0.005;
// 模糊强度（基础值，最终受 master 控制）
uniform float blur_strength : hint_range(0.0, 0.01, 0.0005) = 0.002;
// 色散方向（默认水平，可改为 vec2(0,1) 垂直）
uniform vec2 dispersion_dir = vec2(1.0, 0.0);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

// 内部工具函数：简单均值模糊采样（兼顾性能和效果）
vec4 sample_blur(sampler2D tex, vec2 uv, float blur) {
    vec4 color = vec4(0.0);
    // 3x3 简单采样（8个周围像素+中心，共9个采样点）
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur;
            color += texture(tex, clamp(uv + offset, vec2(0.0), vec2(1.0)));
        }
    }
    return color / 9.0; // 均值合并
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5);
    
    // 1. 计算「中心-边缘权重」：距离中心越远，权重越大（非线性增强边缘效果）
    float dist_to_center = distance(uv, center);
    // pow(2.0) 让边缘权重增长更快，中心（dist=0）权重为0，边缘（dist≈0.5）权重≈1
    float edge_weight = pow(dist_to_center * 2.0, 2.0);
    edge_weight = clamp(edge_weight, 0.0, 1.0); // 限制权重范围，避免异常
    
    // 2. 应用总开关（effect_master）：0 时完全关闭所有效果
    float final_dispersion = dispersion_strength * edge_weight * effect_master;
    float final_blur = blur_strength * effect_master;
    
    // 3. 计算三通道色散偏移（边缘权重直接控制偏移量，中心偏移≈0）
    vec2 offset_r = dispersion_dir * final_dispersion;
    vec2 offset_b = -dispersion_dir * final_dispersion;
    
    // 4. 带模糊的通道采样（每个通道都应用模糊，避免色散+清晰导致的割裂感）
    vec4 color_r = sample_blur(SCREEN_TEXTURE, uv + offset_r, final_blur);
    vec4 color_g = sample_blur(SCREEN_TEXTURE, uv, final_blur);
    vec4 color_b = sample_blur(SCREEN_TEXTURE, uv + offset_b, final_blur);
    
    // 5. 合并三通道+保留透明度
    vec3 final_rgb = vec3(color_r.r, color_g.g, color_b.b);
    float final_a = texture(SCREEN_TEXTURE, uv).a;
    
    // 输出最终颜色（如果 master=0，直接输出原颜色）
    COLOR = mix(texture(SCREEN_TEXTURE, uv), vec4(final_rgb, final_a), effect_master);
}
