shader_type canvas_item;

// 效果控制参数（可在编辑器中实时调节）
uniform float hue_shift : hint_range(-1.0, 1.0, 0.01) = 0.0; // 色相偏移（-1~1对应0~360度）
uniform float twist_strength : hint_range(0.0, 0.1) = 0.02; // 扭曲强度
uniform float twist_frequency : hint_range(1.0, 20.0) = 5.0; // 扭曲频率（波浪密度）
uniform float dispersion_strength : hint_range(0.0, 0.01) = 0.002; // 色散强度
uniform bool radial_twist = false; // 扭曲类型：false=波浪弯曲，true=径向弯曲
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;

// 圆形蒙版参数（绑定到节点本地空间，跟随节点移动）
uniform float mask_radius : hint_range(0.0, 1.0, 0.01) = 0.4; // 蒙版半径（节点UV空间，0-1）
uniform float mask_feather : hint_range(0.0, 0.2, 0.01) = 0.05; // 羽化强度（值越大边缘越柔）
uniform vec2 TEXTURE_SIZE = vec2(1920,1080);

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
    // 1. 获取屏幕UV（用于采样屏幕纹理和扭曲效果）
    vec2 screen_uv = SCREEN_UV;
    vec2 screen_center = vec2(0.5, 0.5); // 扭曲中心仍基于屏幕（也可改为节点中心，看需求）

    // 2. 扭曲弯曲计算（二选一：波浪/径向）
    if (radial_twist) {
        float dist = distance(screen_uv, screen_center);
        float twist = sin(dist * twist_frequency * 6.283) * twist_strength;
        vec2 dir = normalize(screen_uv - screen_center);
        screen_uv += dir * twist;
    } else {
        float twist_x = sin(screen_uv.y * twist_frequency * 6.283 + TIME) * twist_strength;
        float twist_y = cos(screen_uv.x * twist_frequency * 6.283 + TIME) * twist_strength;
        screen_uv += vec2(twist_x, twist_y);
    }

    // 3. 色散效果（RGB通道分离偏移）
    vec3 col;
    col.r = textureLod(SCREEN_TEXTURE, screen_uv + vec2(dispersion_strength, 0.0), 0.0).r;
    col.g = textureLod(SCREEN_TEXTURE, screen_uv + vec2(0.0, 0.0), 0.0).g;
    col.b = textureLod(SCREEN_TEXTURE, screen_uv - vec2(dispersion_strength, 0.0), 0.0).b;

    // 4. 色相调整（基于HSV空间转换）
    vec3 hsv = rgb_to_hsv(col);
    hsv.x = fract(hsv.x + hue_shift);
    col = hsv_to_rgb(hsv);

    // ========== 圆形蒙版+羽化逻辑（绑定到节点本地空间） ==========
    // 节点本地UV中心（0.5,0.5对应节点的中心，跟随节点移动）
    vec2 node_mask_center = vec2(0.5, 0.5);

    // 关键：计算节点纹理的宽高比（适配节点自身的宽高，避免椭圆）
    // TEXTURE_SIZE 是节点纹理的像素尺寸，自动适配节点大小
    float node_aspect = TEXTURE_SIZE.x / TEXTURE_SIZE.y;

    // 校正节点UV：让蒙版在节点范围内显示为正圆
    vec2 corrected_node_uv = (UV - node_mask_center) * vec2(node_aspect, 1.0);

    // 计算校正后当前像素到节点蒙版中心的距离（正圆距离）
    float dist_to_mask_center = length(corrected_node_uv);

    // 校正蒙版半径（保证视觉大小一致）
    float corrected_radius = mask_radius / node_aspect;

    // 计算蒙版Alpha（羽化效果）
    float mask_alpha = smoothstep(
        corrected_radius + mask_feather,
        corrected_radius - mask_feather,
        dist_to_mask_center
    );

    // 应用蒙版（此时蒙版跟随节点移动/缩放）
    COLOR = vec4(col, mask_alpha);
}