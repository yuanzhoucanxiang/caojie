shader_type canvas_item;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float brightness : hint_range(0.5, 1.5) = 1.0;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;
uniform vec3 warm_tint : source_color = vec3(1.0, 0.95, 0.85);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.15;

void fragment() {
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);

	// 亮度调整
	screen.rgb *= brightness;

	// 饱和度调整
	float gray = dot(screen.rgb, vec3(0.299, 0.587, 0.114));
	screen.rgb = mix(vec3(gray), screen.rgb, saturation);

	// 暖色调叠加
	screen.rgb = mix(screen.rgb, screen.rgb * warm_tint, tint_strength);

	// 暗角：画面边缘渐暗
	vec2 centered = SCREEN_UV - 0.5;
	float dist = length(centered / vec2(1.0, 1.0));
	float vignette = 1.0 - dist * vignette_intensity;
	screen.rgb *= vignette;

	COLOR = screen;
}
