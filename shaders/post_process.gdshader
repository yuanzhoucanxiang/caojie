shader_type canvas_item;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.25;
uniform vec4 tint_color : source_color = vec4(1.0, 0.92, 0.82, 0.12);

void fragment() {
	// 暗角：四角渐暗，中心透明
	vec2 centered = UV - 0.5;
	float dist = length(centered / vec2(0.7, 1.0));
	float vignette = smoothstep(0.3, 1.0, dist) * vignette_intensity;

	// 暖色调叠加 + 暗角
	COLOR = vec4(tint_color.rgb, tint_color.a + vignette * 0.25);
}
