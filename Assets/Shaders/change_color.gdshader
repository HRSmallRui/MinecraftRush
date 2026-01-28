shader_type canvas_item;

// 效果控制参数（可在编辑器中实时调节）
uniform float hue_shift : hint_range(-1.0, 1.0, 0.01) = 0.0; // 色相偏移（-1~1对应0~360度）
uniform float twist_strength : hint_range(0.0, 0.1) = 0.02; // 扭曲强度
uniform float twist_frequency : hint_range(1.0, 20.0) = 5.0; // 扭曲频率（波浪密度）
uniform float dispersion_strength : hint_range(0.0, 0.01) = 0.002; // 色散强度
uniform bool radial_twist = false; // 扭曲类型：false=波浪弯曲，true=径向弯曲
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
uniform float master: hint_range(0.0, 1.0, 0.1);

// RGB转HSV（色相调整核心）
vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y)/(6.0*d + e)), d/(q.x + e), q.x);
}

// HSV转RGB（色相调整核心）
vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // 1. 获取原始屏幕UV（屏幕空间坐标）
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5); // 扭曲中心（屏幕中点）

    // 2. 扭曲弯曲计算（二选一：波浪/径向）
    if (radial_twist) {
        // 径向扭曲（中心向外扩散弯曲）
        float dist = distance(uv, center);
        float twist = sin(dist * twist_frequency * 6.283) * twist_strength;
        vec2 dir = normalize(uv - center);
        uv += dir * twist;
    } else {
        // 波浪弯曲（水平/垂直方向波动）
        float twist_x = sin(uv.y * twist_frequency * 6.283 + TIME) * twist_strength;
        float twist_y = cos(uv.x * twist_frequency * 6.283 + TIME) * twist_strength;
        uv += vec2(twist_x, twist_y);
    }

    // 3. 色散效果（RGB通道分离偏移）
    vec3 col;
    // 红光偏移最多，绿光中等，蓝光最少（模拟真实色散）
    col.r = textureLod(SCREEN_TEXTURE, uv + vec2(dispersion_strength, 0.0), 0.0).r;
    col.g = textureLod(SCREEN_TEXTURE, uv + vec2(0.0, 0.0), 0.0).g;
    col.b = textureLod(SCREEN_TEXTURE, uv - vec2(dispersion_strength, 0.0), 0.0).b;

    // 4. 色相调整（基于HSV空间转换）
    vec3 hsv = rgb_to_hsv(col);
    hsv.x = fract(hsv.x + hue_shift); // 循环偏移色相（0~1对应0~360度）
    col = hsv_to_rgb(hsv);

    // 输出最终颜色
    COLOR = mix(COLOR,vec4(col, 1.0),master);
}
