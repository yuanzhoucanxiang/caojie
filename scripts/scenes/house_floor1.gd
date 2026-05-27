## 职责：一楼场景控制器——平视舞台风格，大屋生活区
extends Node2D


const SPAWN_POINTS := {
	"from_outside": Vector2(80, 370),
	"from_2f_down": Vector2(650, 370),
}

# 室内深度参数（同 3 楼）
const INDOOR_DEPTH_MIN: float = 350.0
const INDOOR_DEPTH_MAX: float = 400.0
const INDOOR_SCALE_MIN: float = 0.92
const INDOOR_SCALE_MAX: float = 1.0

# 房间几何
const SCREEN_W: float = 750.0
const SCREEN_H: float = 480.0
const CEILING_H: float = 25.0
const FLOOR_Y: float = 340.0
const WALL_THICK: float = 30.0

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_build_flat_room()
	_hide_old_nodes()
	_setup_post_process()
	_add_depth_lighting()
	_add_wall_collisions()
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
	var lw := 2.0

	draw_line(Vector2(0, FLOOR_Y), Vector2(SCREEN_W, FLOOR_Y), Color(1.0, 0.25, 0.15, 0.7), lw)
	draw_string(font, Vector2(5, FLOOR_Y - 5), "地面 y=340", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	draw_rect(Rect2(0, CEILING_H, SCREEN_W, FLOOR_Y - CEILING_H), Color(0.2, 0.5, 1.0, 0.5), false, 1.5)
	draw_line(Vector2(0, CEILING_H), Vector2(SCREEN_W, CEILING_H), Color(1.0, 0.85, 0.1, 0.6), 1.5)

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

	# 1F: WALL_TOP=30px, WALL_BOT=8px
	_add_wall_perspective(30, 8)

	# 后墙
	_add_poly("StructBackWall", 30, CEILING_H, SCREEN_W - 60, FLOOR_Y - CEILING_H,
		Color(0.82, 0.76, 0.62, 1), TextureSetup.Pattern.NOISE, 100.0, 0.06, -90)

	# 地板：梯形
	_add_face("StructFloor", [
		Vector2(8, SCREEN_H), Vector2(SCREEN_W - 8, SCREEN_H),
		Vector2(SCREEN_W - 30, FLOOR_Y), Vector2(30, FLOOR_Y),
	], Color(0.48, 0.38, 0.26, 1), TextureSetup.Pattern.WOOD_H, 80.0, 0.1, 0)


func _add_wall_perspective(top_w: float, bot_w: float) -> void:
	_add_face("StructLeftWall", [
		Vector2(0, CEILING_H), Vector2(top_w, CEILING_H),
		Vector2(bot_w, SCREEN_H), Vector2(0, SCREEN_H),
	], Color(0.48, 0.4, 0.3, 1), TextureSetup.Pattern.WOOD_V, 60.0, 0.06, -80)

	_add_face("StructRightWall", [
		Vector2(SCREEN_W - top_w, CEILING_H), Vector2(SCREEN_W, CEILING_H),
		Vector2(SCREEN_W, SCREEN_H), Vector2(SCREEN_W - bot_w, SCREEN_H),
	], Color(0.45, 0.38, 0.28, 1), TextureSetup.Pattern.WOOD_V, 60.0, 0.06, -80)


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


func _hide_old_nodes() -> void:
	var to_hide := [
		"Floor", "BackWall", "LeftWall", "RightWall",
		"Counter", "Shelves", "RoundTable", "Chair", "Chair1", "Chair2",
		"TV", "Stove", "StoveTop", "WaterTank", "StorageDoor",
	]
	for node_name in to_hide:
		var n := get_node_or_null(node_name)
		if n and n is ColorRect:
			n.modulate.a = 0.0


# ============================================================
# 碰撞体
# ============================================================

func _add_wall_collisions() -> void:
	_add_hitbox("WallLeft", Vector2(0, 0), Vector2(WALL_THICK + 2, SCREEN_H))
	_add_hitbox("WallRight", Vector2(SCREEN_W - WALL_THICK - 2, 0), Vector2(WALL_THICK + 2, SCREEN_H))


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
	mat.set_shader_parameter("vignette_intensity", 0.2)
	mat.set_shader_parameter("tint_color", Color(1.0, 0.9, 0.75, 0.12))

	var overlay := ColorRect.new()
	overlay.name = "PostProcess"
	overlay.material = mat
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000
	add_child(overlay)
	overlay.size = Vector2(SCREEN_W, SCREEN_H)


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
