shader_type canvas_item;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.25;
uniform vec4 tint_color : source_color = vec4(1.0, 0.92, 0.82, 0.08);

void fragment() {
	// 到中心的距离，0=中心，1=最远角
	vec2 centered = UV - 0.5;
	float dist = length(centered) * 1.4;

	// 柔化暗角：没有起始边界，从头到尾平滑过渡
	float vignette = smoothstep(0.0, 1.0, dist) * vignette_intensity * 0.3;

	// 暖色调叠加 + 柔暗角
	float alpha = tint_color.a + vignette;
	COLOR = vec4(tint_color.rgb, alpha);
}
