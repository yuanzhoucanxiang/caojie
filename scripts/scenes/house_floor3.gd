## 职责：三楼场景控制器——平视舞台风格（Long Gone 参考），主角房间、天台入口
extends Node2D


const SPAWN_POINTS := {
	"from_2f_up": Vector2(255, 375),
}

# 室内深度参数
const INDOOR_DEPTH_MIN: float = 330.0
const INDOOR_DEPTH_MAX: float = 400.0
const INDOOR_SCALE_MIN: float = 0.92
const INDOOR_SCALE_MAX: float = 1.0

# 房间几何
const SCREEN_W: float = 510.0
const SCREEN_H: float = 480.0
const CEILING_H: float = 25.0
const FLOOR_Y: float = 340.0
const WALL_THICK: float = 30.0

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_apply_textures()
	_build_flat_room()
	_build_furniture()
	_hide_old_nodes()
	_setup_post_process()
	_add_depth_lighting()
	_add_wall_collisions()
	_add_furniture_collisions()
	_add_interactable_objects()
	_add_pause_menu()
	_apply_spawn()
	player.add_to_group("player")
	_bind_all_npcs()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	queue_redraw()


# ============================================================
# 线框标注
# ============================================================

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var fs := 10
	var bold := Color.WHITE
	var lw := 2.0

	# 地面线
	draw_line(Vector2(0, FLOOR_Y), Vector2(SCREEN_W, FLOOR_Y), Color(1.0, 0.25, 0.15, 0.7), lw)
	draw_string(font, Vector2(5, FLOOR_Y - 5), "地面 y=340", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, bold)

	# 后墙
	draw_rect(Rect2(0, CEILING_H, SCREEN_W, FLOOR_Y - CEILING_H), Color(0.2, 0.5, 1.0, 0.5), false, 1.5)

	# 天花板
	draw_line(Vector2(0, CEILING_H), Vector2(SCREEN_W, CEILING_H), Color(1.0, 0.85, 0.1, 0.6), 1.5)

	# 深度范围
	var dc := Color(0.1, 0.9, 0.9, 0.4)
	draw_dashed_line(Vector2(0, INDOOR_DEPTH_MIN), Vector2(SCREEN_W, INDOOR_DEPTH_MIN), dc, 1.0, 5.0)
	draw_dashed_line(Vector2(0, INDOOR_DEPTH_MAX), Vector2(SCREEN_W, INDOOR_DEPTH_MAX), dc, 1.0, 5.0)


# ============================================================
# 房间结构
# ============================================================

func _build_flat_room() -> void:
	# 天花板
	_add_poly("StructCeiling", 0, 0, SCREEN_W, CEILING_H,
		Color(0.32, 0.28, 0.22, 1), TextureSetup.Pattern.NOISE, 100.0, 0.02, -100)

	# 墙壁内边沿：顶部宽（远离镜头），底部窄（靠近镜头）→ 斜线产生透视感
	# 3F: WALL_TOP=25px, WALL_BOT=5px
	_add_wall_perspective(25, 5)

	# 后墙：在两面墙之间
	_add_poly("StructBackWall", 25, CEILING_H, SCREEN_W - 50, FLOOR_Y - CEILING_H,
		Color(0.82, 0.76, 0.62, 1), TextureSetup.Pattern.NOISE, 100.0, 0.06, -90)

	# 地板：梯形（底部宽、顶部窄）
	_add_face("StructFloor", [
		Vector2(5, SCREEN_H), Vector2(SCREEN_W - 5, SCREEN_H),
		Vector2(SCREEN_W - 25, FLOOR_Y), Vector2(25, FLOOR_Y),
	], Color(0.48, 0.38, 0.26, 1), TextureSetup.Pattern.WOOD_H, 80.0, 0.1, 0)


func _add_wall_perspective(top_w: float, bot_w: float) -> void:
	# 左墙：内边沿从 (top_w, 340) 斜到 (bot_w, 480)
	_add_face("StructLeftWall", [
		Vector2(0, CEILING_H), Vector2(top_w, CEILING_H),
		Vector2(bot_w, SCREEN_H), Vector2(0, SCREEN_H),
	], Color(0.48, 0.4, 0.3, 1), TextureSetup.Pattern.WOOD_V, 60.0, 0.06, -80)

	# 右墙：镜像
	_add_face("StructRightWall", [
		Vector2(SCREEN_W - top_w, CEILING_H), Vector2(SCREEN_W, CEILING_H),
		Vector2(SCREEN_W, SCREEN_H), Vector2(SCREEN_W - bot_w, SCREEN_H),
	], Color(0.45, 0.38, 0.28, 1), TextureSetup.Pattern.WOOD_V, 60.0, 0.06, -80)


# ============================================================
# 家具布置
# ============================================================

func _build_furniture() -> void:
	# ========== 后墙物品 ==========

	# 窗户 + 十字窗框（居中）
	_add_poly("FurnWindow", 140, 70, 230, 115,
		Color(0.55, 0.72, 0.82, 1), TextureSetup.Pattern.NOISE, 100.0, 0.02, 185)
	_add_poly("FurnWinBarH", 140, 125, 230, 5,
		Color(0.35, 0.28, 0.2, 1), TextureSetup.Pattern.WOOD_H, 30.0, 0.05, 190)
	_add_poly("FurnWinBarV", 252, 70, 5, 115,
		Color(0.35, 0.28, 0.2, 1), TextureSetup.Pattern.WOOD_V, 30.0, 0.05, 190)

	# 海报（右上墙）
	_add_poly("FurnPoster", 430, 80, 50, 70,
		Color(0.72, 0.55, 0.45, 1), TextureSetup.Pattern.NOISE, 70.0, 0.04, 150)

	# 书架（右墙，窗和海报之间，靠上）
	_add_poly("FurnBookshelf", 390, 235, 48, 105,
		Color(0.42, 0.33, 0.2, 1), TextureSetup.Pattern.WOOD_V, 40.0, 0.08, 340)
	_add_poly("FurnShelf1", 392, 265, 44, 4,
		Color(0.48, 0.38, 0.24, 1), TextureSetup.Pattern.WOOD_H, 25.0, 0.05, 270)
	_add_poly("FurnShelf2", 392, 298, 44, 4,
		Color(0.48, 0.38, 0.24, 1), TextureSetup.Pattern.WOOD_H, 25.0, 0.05, 303)
	for i in range(3):
		_add_poly("FurnBook%d" % i, 394 + i * 13, 242, 10, 22,
			Color(0.5 + i * 0.12, 0.3 + i * 0.08, 0.25 + i * 0.1, 1), TextureSetup.Pattern.NOISE, 18.0, 0.02, 265)

	# ========== 地面物品 ==========

	# 床（左墙，紧凑型）
	_add_poly("FurnBedFrame", 25, 335, 80, 55,
		Color(0.45, 0.35, 0.22, 1), TextureSetup.Pattern.WOOD_H, 50.0, 0.1, 390)
	_add_poly("FurnMattress", 30, 340, 70, 38,
		Color(0.68, 0.58, 0.42, 1), TextureSetup.Pattern.NOISE, 50.0, 0.06, 379)
	_add_poly("FurnPillow", 33, 330, 32, 12,
		Color(0.82, 0.78, 0.68, 1), TextureSetup.Pattern.NOISE, 40.0, 0.03, 343)
	_add_poly("FurnBlanket", 65, 342, 32, 32,
		Color(0.62, 0.52, 0.36, 1), TextureSetup.Pattern.NOISE, 40.0, 0.05, 375)

	# 书桌（右墙，紧凑型）
	_add_poly("FurnDesk", 370, 338, 95, 10,
		Color(0.48, 0.38, 0.24, 1), TextureSetup.Pattern.WOOD_H, 50.0, 0.1, 349)
	_add_poly("FurnDeskLeg1", 378, 348, 6, 42, Color(0.4, 0.32, 0.2, 1), TextureSetup.Pattern.WOOD_V, 18.0, 0.05, 391)
	_add_poly("FurnDeskLeg2", 450, 348, 6, 42, Color(0.4, 0.32, 0.2, 1), TextureSetup.Pattern.WOOD_V, 18.0, 0.05, 391)

	# 椅子（紧贴书桌）
	_add_poly("FurnChairSeat", 395, 365, 32, 8,
		Color(0.46, 0.36, 0.22, 1), TextureSetup.Pattern.WOOD_H, 35.0, 0.08, 374)
	_add_poly("FurnChairBack", 395, 345, 5, 25,
		Color(0.44, 0.34, 0.2, 1), TextureSetup.Pattern.WOOD_V, 18.0, 0.05, 371)
	_add_poly("FurnChairLegL", 399, 373, 4, 17, Color(0.4, 0.3, 0.18, 1), TextureSetup.Pattern.WOOD_V, 12.0, 0.05, 391)
	_add_poly("FurnChairLegR", 420, 373, 4, 17, Color(0.4, 0.3, 0.18, 1), TextureSetup.Pattern.WOOD_V, 12.0, 0.05, 391)

	# 桌上物品
	_add_poly("FurnNotebook", 382, 326, 38, 22,
		Color(0.88, 0.85, 0.78, 1), TextureSetup.Pattern.NOISE, 35.0, 0.02, 349)
	_add_poly("FurnPencil", 425, 322, 4, 28,
		Color(0.75, 0.65, 0.38, 1), TextureSetup.Pattern.WOOD_V, 12.0, 0.03, 351)
	_add_poly("FurnLampBase", 435, 322, 18, 14,
		Color(0.35, 0.3, 0.25, 1), TextureSetup.Pattern.NOISE, 25.0, 0.03, 337)

	# 地毯（中央地面）
	_add_poly("FurnRug", 145, 385, 220, 20,
		Color(0.56, 0.34, 0.2, 1), TextureSetup.Pattern.NOISE, 80.0, 0.08, 406)

	# 书包（左墙角落）
	_add_poly("FurnBackpack", 22, 378, 28, 30,
		Color(0.28, 0.38, 0.25, 1), TextureSetup.Pattern.NOISE, 35.0, 0.06, 409)

	# 衣物堆（床脚边，靠墙）
	_add_poly("FurnClothes", 108, 388, 22, 14,
		Color(0.55, 0.5, 0.42, 1), TextureSetup.Pattern.NOISE, 35.0, 0.06, 403)


func _add_poly(poly_name: String, x: float, y: float, w: float, h: float, color: Color, pattern: int, tex_scale: float, noise: float, z: int) -> void:
	var poly := Polygon2D.new()
	poly.name = poly_name
	poly.polygon = PackedVector2Array([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])
	poly.color = color
	poly.z_index = z
	poly.z_as_relative = false

	var shader := load("res://shaders/procedural_texture.gdshader") as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("base_color", color)
		mat.set_shader_parameter("pattern", pattern)
		mat.set_shader_parameter("texture_scale", tex_scale)
		mat.set_shader_parameter("noise_intensity", noise)
		poly.material = mat

	add_child(poly)


func _add_face(poly_name: String, verts: Array, color: Color, pattern: int, tex_scale: float, noise: float, z: int) -> void:
	var poly := Polygon2D.new()
	poly.name = poly_name
	poly.polygon = PackedVector2Array(verts)
	poly.color = color
	poly.z_index = z
	poly.z_as_relative = false
	var shader := load("res://shaders/procedural_texture.gdshader") as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("base_color", color)
		mat.set_shader_parameter("pattern", pattern)
		mat.set_shader_parameter("texture_scale", tex_scale)
		mat.set_shader_parameter("noise_intensity", noise)
		poly.material = mat
	add_child(poly)


func _hide_old_nodes() -> void:
	for node_name in ["Floor", "BackWall", "LeftWall", "RightWall", "Bed", "Desk", "Window", "WindowFrame"]:
		var n := get_node_or_null(node_name)
		if n and n is ColorRect:
			n.modulate.a = 0.0


# ============================================================
# 碰撞体
# ============================================================

func _add_wall_collisions() -> void:
	_add_hitbox("WallLeft", Vector2(0, 0), Vector2(WALL_THICK + 2, SCREEN_H))
	_add_hitbox("WallRight", Vector2(SCREEN_W - WALL_THICK - 2, 0), Vector2(WALL_THICK + 2, SCREEN_H))


func _add_furniture_collisions() -> void:
	_add_hitbox("Bed", Vector2(25, 345), Vector2(80, 45))
	_add_hitbox("Desk", Vector2(370, 345), Vector2(95, 45))
	_add_hitbox("Bookshelf", Vector2(390, 260), Vector2(48, 80))


func _add_hitbox(obj_name: String, pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = obj_name
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = size / 2.0
	body.add_child(shape)
	add_child(body)


# ============================================================
# 可互动物品
# ============================================================

func _add_interactable_objects() -> void:
	var bed := InteractableObject.new()
	bed.position = Vector2(25, 345)
	bed.setup("Bed", "一张小木床，被子叠得整整齐齐。躺上去应该很舒服。", 80, 45)
	add_child(bed)

	var desk := InteractableObject.new()
	desk.position = Vector2(370, 345)
	desk.setup("Desk", "桌上摊着课本和作业本，铅笔滚到了桌角。", 95, 45)
	add_child(desk)

	var window_obj := InteractableObject.new()
	window_obj.position = Vector2(140, 70)
	window_obj.setup("Window", "窗外能看到村子的屋顶和远处的鱼塘，天很蓝。", 230, 115)
	add_child(window_obj)

	var shelf := InteractableObject.new()
	shelf.position = Vector2(390, 235)
	shelf.setup("Bookshelf", "几本旧课本和一本翻烂了的《西游记》小人书。", 48, 105)
	add_child(shelf)

	var poster := InteractableObject.new()
	poster.position = Vector2(430, 80)
	poster.setup("Poster", "一张褪色的动画片海报，边角已经卷起来了。", 50, 70)
	add_child(poster)

	var backpack := InteractableObject.new()
	backpack.position = Vector2(22, 378)
	backpack.setup("Backpack", "书包扔在角落，拉链都没拉好。", 28, 30)
	add_child(backpack)


# ============================================================
# 光照/出生点/暂停/后处理
# ============================================================

func _add_depth_lighting() -> void:
	var top := ColorRect.new()
	top.name = "TopShadow"
	top.position = Vector2(0, 0)
	top.size = Vector2(SCREEN_W, CEILING_H + 50)
	top.color = Color(0.06, 0.04, 0.02, 0.32)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.z_index = 50
	add_child(top)

	var mid := ColorRect.new()
	mid.name = "MidShadow"
	mid.position = Vector2(0, FLOOR_Y - 30)
	mid.size = Vector2(SCREEN_W, 50)
	mid.color = Color(0.06, 0.04, 0.02, 0.1)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mid.z_index = 50
	add_child(mid)


func _apply_spawn() -> void:
	var sid := SceneManager.get_pending_spawn()
	if sid.is_empty():
		return
	var pos: Vector2 = SPAWN_POINTS.get(sid, Vector2.ZERO)
	if pos != Vector2.ZERO:
		player.position = pos


func _add_pause_menu() -> void:
	add_child(load("res://scenes/ui/pause_menu.tscn").instantiate())


func _setup_post_process() -> void:
	var shader := load("res://shaders/post_process.gdshader") as Shader
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("vignette_intensity", 0.3)
	mat.set_shader_parameter("tint_color", Color(1.0, 0.88, 0.72, 0.14))

	var overlay := ColorRect.new()
	overlay.name = "PostProcess"
	overlay.material = mat
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	add_child(overlay)
	overlay.size = Vector2(SCREEN_W, SCREEN_H)


func _apply_textures() -> void:
	# 旧 tscn 家具已被隐藏，不需要纹理
	pass


func _bind_all_npcs() -> void:
	for child in get_children():
		if child.has_signal("dialogue_request"):
			child.dialogue_request.connect(
				func(npc, data): DialogueManager.start_dialogue(npc, data)
			)


func _on_dialogue_started() -> void:
	player.set_physics_process(false)
	player.set_process(false)


func _on_dialogue_finished() -> void:
	player.set_physics_process(true)
	player.set_process(true)
