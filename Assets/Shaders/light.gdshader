shader_type canvas_item;

// 描边粗细（范围0.0~10.0，步长0.1，默认1.0）
// hint_range用于在编辑器中提供滑动条，方便调试
uniform float outline_width : hint_range(0.0, 100.0, 0.1) = 1.0;
// 描边颜色（带透明度，默认黑色不透明）
// source_color让编辑器显示颜色选择器，更直观
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // 1. 采样当前像素的原始颜色（保留原图内容）
    vec4 original_color = texture(TEXTURE, UV);

    // 2. 计算采样步长：基于屏幕UV和描边粗细，适配不同分辨率
    // SCREEN_PIXEL_SIZE是屏幕单个像素的UV尺寸，保证不同分辨率下描边粗细一致
    vec2 pixel_step = SCREEN_PIXEL_SIZE * outline_width;

    // 3. 采样上下左右四个方向的像素，检测边缘
    float edge = 0.0;
    edge += texture(TEXTURE, UV + vec2(pixel_step.x, 0.0)).a; // 右
    edge += texture(TEXTURE, UV - vec2(pixel_step.x, 0.0)).a; // 左
    edge += texture(TEXTURE, UV + vec2(0.0, pixel_step.y)).a; // 上
    edge += texture(TEXTURE, UV - vec2(0.0, pixel_step.y)).a; // 下

    // 4. 边缘判断：如果周围有不透明像素，但当前像素透明，说明是边缘
    // edge > 0.0 表示周围有像素，original_color.a < 0.1 表示当前像素透明
    bool is_outline = (edge > 0.0) && (original_color.a < 0.1);

    // 5. 混合描边颜色和原始颜色
    if (is_outline) {
        // 边缘区域显示描边颜色（保留描边的透明度）
        COLOR = outline_color;
    } else {
        // 非边缘区域保留原图颜色
        COLOR = original_color;
    }
}