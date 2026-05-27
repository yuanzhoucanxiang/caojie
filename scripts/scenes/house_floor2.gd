## 职责：二楼场景控制器——走廊，连接一楼和三楼
extends Node2D


const SPAWN_POINTS := {
	"from_1f_up": Vector2(85, 370),
	"from_3f_down": Vector2(560, 370),
}

# 房间参数
const SCREEN_W: float = 640.0
const SCREEN_H: float = 480.0
const CEILING_H: float = 25.0
const FLOOR_Y: float = 340.0

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	_build_room()
	_hide_old_floor_wall()
	_setup_post_process()
	_add_depth_lighting()
	_add_wall_collisions()
	_add_pause_menu()
	_apply_spawn()
	player.add_to_group("player")
	_bind_all_npcs()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)


# ============================================================
# 房间结构
# ============================================================

func _build_room() -> void:
	# 天花板
	_add_poly("StructCeiling", 0, 0, SCREEN_W, CEILING_H,
		Color(0.3, 0.26, 0.2, 1), TextureSetup.Pattern.NOISE, 100.0, 0.02, -100)

	# 墙壁：顶部25px，底部5px，斜线内边沿
	# 2F 独有色：左墙偏暖、右墙偏冷，区别于1F和3F
	_add_face("StructLeftWall", [
		Vector2(0, CEILING_H), Vector2(25, CEILING_H),
		Vector2(5, SCREEN_H), Vector2(0, SCREEN_H),
	], Color(0.52, 0.42, 0.32, 1), TextureSetup.Pattern.WOOD_V, 60.0, 0.06, -80)

	_add_face("StructRightWall", [
		Vector2(SCREEN_W - 25, CEILING_H), Vector2(SCREEN_W, CEILING_H),
		Vector2(SCREEN_W, SCREEN_H), Vector2(SCREEN_W - 5, SCREEN_H),
	], Color(0.4, 0.36, 0.28, 1), TextureSetup.Pattern.WOOD_V, 60.0, 0.06, -80)

	# 后墙：在墙壁之间（走廊背景色）
	_add_poly("StructBackWall", 25, CEILING_H, SCREEN_W - 50, FLOOR_Y - CEILING_H,
		Color(0.78, 0.72, 0.58, 1), TextureSetup.Pattern.NOISE, 100.0, 0.06, -90)

	# 地板：梯形
	_add_face("StructFloor", [
		Vector2(5, SCREEN_H), Vector2(SCREEN_W - 5, SCREEN_H),
		Vector2(SCREEN_W - 25, FLOOR_Y), Vector2(25, FLOOR_Y),
	], Color(0.46, 0.36, 0.24, 1), TextureSetup.Pattern.WOOD_H, 80.0, 0.1, 0)


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


func _hide_old_floor_wall() -> void:
	# 只隐藏旧的地板和墙壁，保留三个房间色块
	for node_name in ["Floor", "BackWall", "LeftWall", "RightWall"]:
		var n := get_node_or_null(node_name)
		if n and n is ColorRect:
			n.modulate.a = 0.0


# ============================================================
# 光影
# ============================================================

func _add_depth_lighting() -> void:
	var top := ColorRect.new()
	top.name = "TopShadow"
	top.position = Vector2(0, 0)
	top.size = Vector2(SCREEN_W, CEILING_H + 50)
	top.color = Color(0.06, 0.04, 0.02, 0.3)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.z_index = 50
	add_child(top)

	var mid := ColorRect.new()
	mid.name = "MidShadow"
	mid.position = Vector2(0, FLOOR_Y - 30)
	mid.size = Vector2(SCREEN_W, 50)
	mid.color = Color(0.06, 0.04, 0.02, 0.08)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mid.z_index = 50
	add_child(mid)


# ============================================================
# 碰撞体
# ============================================================

func _add_wall_collisions() -> void:
	_add_hitbox("WallLeft", Vector2(0, 0), Vector2(32, SCREEN_H))
	_add_hitbox("WallRight", Vector2(SCREEN_W - 32, 0), Vector2(32, SCREEN_H))


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
# 出生点/暂停/后处理
# ============================================================

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
	mat.set_shader_parameter("vignette_intensity", 0.18)
	mat.set_shader_parameter("tint_color", Color(1.0, 0.86, 0.7, 0.12))

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
