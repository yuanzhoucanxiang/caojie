## 职责：程序化生成像素纹理（砖墙、木纹、泥土等），输出 ImageTexture
## 谁使用它：场景控制器或 Sprite2D 节点
## 它使用谁：Godot Image / ImageTexture

class_name TextureGenerator
extends RefCounted


static func brick_wall(
	brick_c: Color = Color(0.58, 0.35, 0.25),
	mortar_c: Color = Color(0.35, 0.28, 0.2),
	tile_size: int = 64,
) -> ImageTexture:
	var img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	img.fill(mortar_c)
	var brick_h := 8
	var brick_w := 16
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for row in range(0, tile_size + brick_h, brick_h):
		var off: int = ((row / brick_h) % 2) * (brick_w / 2)
		for col in range(-brick_w, tile_size + brick_w, brick_w):
			var bx := col + off
			var br := rng.randf_range(0.88, 1.06)
			var bg := rng.randf_range(0.88, 1.06)
			var bb := rng.randf_range(0.88, 1.06)
			var c := Color(brick_c.r * br, brick_c.g * bg, brick_c.b * bb, 1.0)
			_fill_rect_safe(img, bx + 1, row + 1, brick_w - 2, brick_h - 2, c, tile_size)
	return ImageTexture.create_from_image(img)


static func wood_planks(
	wood_c: Color = Color(0.4, 0.28, 0.15),
	gap_c: Color = Color(0.25, 0.18, 0.1),
	tile_size: int = 64,
) -> ImageTexture:
	var img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	img.fill(gap_c)
	var plank_h := 12
	var rng := RandomNumberGenerator.new()
	rng.seed = 57
	for row in range(0, tile_size, plank_h):
		var wr := rng.randf_range(0.9, 1.05)
		var wg := rng.randf_range(0.9, 1.05)
		var wb := rng.randf_range(0.9, 1.05)
		var c := Color(wood_c.r * wr, wood_c.g * wg, wood_c.b * wb, 1.0)
		_fill_rect_safe(img, 0, row, tile_size, plank_h - 1, c, tile_size)
		# 木纹细线
		for x in range(0, tile_size, 4):
			var line_c := Color(c.r * 0.92, c.g * 0.92, c.b * 0.92, 1.0)
			img.set_pixel(x + (row % 2), row + plank_h / 2, line_c)
	return ImageTexture.create_from_image(img)


static func dirt_ground(
	base_c: Color = Color(0.48, 0.42, 0.3),
	tile_size: int = 64,
) -> ImageTexture:
	var img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 83
	for y in tile_size:
		for x in tile_size:
			var v := rng.randf_range(0.88, 1.06)
			var gr := base_c.g * v * rng.randf_range(0.94, 1.03)
			var bl := base_c.b * v * rng.randf_range(0.92, 1.02)
			var c := Color(base_c.r * v, gr, bl, 1.0)
			img.set_pixel(x, y, c)
	# 撒一些小石子
	for _i in range(20):
		var sx := rng.randi_range(0, tile_size - 1)
		var sy := rng.randi_range(0, tile_size - 1)
		var sc := Color(base_c.r * 0.6, base_c.g * 0.6, base_c.b * 0.55, 1.0)
		img.set_pixel(sx, sy, sc)
	return ImageTexture.create_from_image(img)


static func noise_texture(
	base_c: Color = Color(0.7, 0.65, 0.5),
	tile_size: int = 64,
	intensity: float = 0.06,
) -> ImageTexture:
	var img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 101
	for y in tile_size:
		for x in tile_size:
			var v := rng.randf_range(1.0 - intensity, 1.0 + intensity)
			var c := Color(base_c.r * v, base_c.g * v, base_c.b * v, 1.0)
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


static func _fill_rect_safe(
	img: Image, x: int, y: int, w: int, h: int, color: Color, size: int,
) -> void:
	var rx := max(0, x)
	var ry := max(0, y)
	var rw := min(w, size - rx)
	var rh := min(h, size - ry)
	if rw > 0 and rh > 0:
		img.fill_rect(Rect2i(rx, ry, rw, rh), color)
