shader_type canvas_item;

uniform sampler2D noise_tex : filter_linear, repeat_enable;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.95, 0.93, 0.88, 1.0);
uniform float noise_scale = 6.0;
uniform float pixel_block = 6.0;

void fragment() {
	// 像素化
	vec2 pix = floor(UV / pixel_block) * pixel_block;

	// 到屏幕边缘的距离 [0, 0.5]（边缘=0，中心=0.5）
	float edge_dist = min(min(pix.x, 1.0 - pix.x), min(pix.y, 1.0 - pix.y));

	// 两层噪声
	float n1 = texture(noise_tex, pix * noise_scale).r;
	float n2 = texture(noise_tex, pix * noise_scale * 1.7 + vec2(3.14, 1.62)).r;
	float n = mix(n1, n2, 0.5);

	// 覆盖度 = (0.5 - 边缘距离) + 噪声扰动
	// 边缘像素覆盖度高（接近0.6），中心低（接近0）
	// 高噪声值让某些边缘区域更容易被覆盖（先出现）
	float coverage = (0.5 - edge_dist) + n * 0.15;

	// dissolve 控制覆盖范围：覆盖度 < dissolve 的区域被水彩覆盖
	// dissolve=0 时 coverage 始终 >= 0，step 返回 0，完全透明
	float mask = step(coverage, dissolve);

	// 水彩边缘柔化
	float fringe = smoothstep(dissolve, dissolve - 0.08, coverage);
	mask = max(mask, fringe * 0.6) * step(0.001, dissolve);

	COLOR = vec4(tint.rgb, mask * 0.92);
}
