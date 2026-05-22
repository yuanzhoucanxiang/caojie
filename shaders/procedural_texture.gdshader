shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.5, 0.4, 0.3, 1.0);
uniform float texture_scale = 64.0;
uniform float noise_intensity : hint_range(0.0, 0.25) = 0.08;
uniform int pattern = 0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise2d(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
		mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x),
		f.y
	);
}

void fragment() {
	vec2 uv = UV * texture_scale;
	float n = noise2d(uv);
	float n2 = noise2d(uv * 2.3 + 1.7);
	vec3 col = base_color.rgb;
	float dark;
	float bright;

	if (pattern == 0) {
		// 通用噪点 — 墙面/水泥/灰泥
		col = mix(col, col * (0.82 + 0.36 * n + 0.08 * n2), noise_intensity);
	} else if (pattern == 1) {
		// 砖墙
		float row = floor(uv.y);
		float off = mod(row, 2.0) * 0.5;
		float col_idx = floor(uv.x + off);
		float bx = fract(uv.x + off);
		float by = fract(uv.y);
		dark = (step(0.93, bx) + step(0.93, by)) * 0.28;
		bright = noise_intensity * (0.85 + 0.3 * n);
		col = mix(col, col * 0.55, dark);
		col = mix(col, col * 1.08, bright * (1.0 - dark));
	} else if (pattern == 2) {
		// 横木纹 — 地板、桌面
		float grain = sin(uv.y * 10.0 + n * 4.0) * 0.5 + 0.5;
		col = mix(col, col * (0.82 + 0.36 * grain + 0.06 * n2), noise_intensity * 1.2);
	} else if (pattern == 3) {
		// 竖木纹 — 柱子、栅栏
		float grain = sin(uv.x * 8.0 + n * 3.5) * 0.5 + 0.5;
		col = mix(col, col * (0.82 + 0.36 * grain + 0.06 * n2), noise_intensity * 1.2);
	} else if (pattern == 4) {
		// 泥土/地面 — 斑点+色差
		float specks = step(0.88, hash21(floor(uv * 1.5)));
		dark = specks * noise_intensity * 1.5;
		bright = n * noise_intensity * 0.6 + n2 * noise_intensity * 0.3;
		col = mix(col, col * 0.78, dark);
		col = mix(col, col * 1.08, bright);
	} else if (pattern == 5) {
		// 草地 — 草叶方向感+噪点
		float grass = step(0.72, n) * step(0.55, n2);
		col = mix(col, col * (0.85 + 0.3 * (n + n2)), noise_intensity);
		col = mix(col, col * 1.12, grass * noise_intensity * 0.4);
	}

	COLOR = vec4(col, base_color.a);
}
