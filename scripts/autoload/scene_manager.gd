## 职责：场景切换管理——水彩过渡动画、室内外镜头切换
## 谁使用它：场景边界触发器（StaticBody2D）
## 它使用谁：watercolor_transition shader

extends Node

signal transition_completed

var _overlay: ColorRect
var _fade_overlay: ColorRect
var _shader_material: ShaderMaterial
var _noise_texture: NoiseTexture2D
var _is_transitioning: bool = false

const CAMERA_CONFIGS = {
	"courtyard": {"zoom": 1.25},
	"house_floor1": {"zoom": 1.5},
	"house_floor2": {"zoom": 1.5},
	"house_floor3": {"zoom": 1.8},
	"village_road": {"zoom": 0.9},
}

var _current_area: String = "courtyard"


func _ready() -> void:
	# 创建噪声纹理（FastNoiseLite 生成有机纹理）
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = randi()
	noise.frequency = 0.006

	_noise_texture = NoiseTexture2D.new()
	_noise_texture.noise = noise
	_noise_texture.width = 512
	_noise_texture.height = 512
	_noise_texture.seamless = true
	# 等待噪声纹理生成完成
	await _noise_texture.changed

	# 加载 shader
	var shader = load("res://shaders/watercolor_transition.gdshader") as Shader
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = shader
	_shader_material.set_shader_parameter("noise_tex", _noise_texture)
	_shader_material.set_shader_parameter("dissolve", 0.0)

	# 创建全屏遮罩（水彩层）
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.z_index = 4096
	_overlay.material = _shader_material
	add_child(_overlay)

	# 褪色层：用场景暖色调（默认院子土黄色），过渡时叠加褪色感
	_fade_overlay = ColorRect.new()
	_fade_overlay.color = Color(0.85, 0.8, 0.7, 0)
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.z_index = 4095
	add_child(_fade_overlay)


func _process(_delta: float) -> void:
	# 确保遮罩始终覆盖全屏
	var viewport_size = get_viewport().get_visible_rect().size
	if _overlay and is_instance_valid(_overlay):
		_overlay.size = viewport_size
	if _fade_overlay and is_instance_valid(_fade_overlay):
		_fade_overlay.size = viewport_size


func change_to_packed(packed_scene: PackedScene, area_id: String = "courtyard", transition_color: Color = Color(0, 0, 0, 1)) -> void:
	print("【场景】开始切换")
	if _is_transitioning:
		return
	_is_transitioning = true

	# 设置水彩颜色 + 褪色层用场景主色调（初始透明）
	_shader_material.set_shader_parameter("tint", transition_color)
	_fade_overlay.color = Color(transition_color.r, transition_color.g, transition_color.b, 0.0)

	# 水彩扩散（0→1）+ 褪色（alpha 0→0.5）
	var tween_out = create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_method(_set_dissolve, 0.0, 1.0, 0.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_out.tween_property(_fade_overlay, "color:a", 0.5, 0.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween_out.finished

	# 水彩完全覆盖后短暂停顿，确保场景切换在遮罩下完成
	await get_tree().create_timer(0.15).timeout

	# 切换场景
	var new_instance = packed_scene.instantiate()
	var old = get_tree().current_scene
	if old:
		get_tree().root.remove_child(old)
		old.queue_free()

	get_tree().root.add_child(new_instance)
	get_tree().current_scene = new_instance
	_current_area = area_id
	print("【场景】新场景已就位: ", new_instance.name)

	await get_tree().process_frame
	_apply_camera_config(area_id)

	# 水彩退去（1→0）+ 画面恢复（alpha 0.5→0）
	var tween_in = create_tween()
	tween_in.set_parallel(true)
	tween_in.tween_method(_set_dissolve, 1.0, 0.0, 0.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween_in.tween_property(_fade_overlay, "color:a", 0.0, 0.8) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween_in.finished

	_shader_material.set_shader_parameter("dissolve", 0.0)
	_fade_overlay.color = Color(0.85, 0.8, 0.7, 0)
	_is_transitioning = false
	transition_completed.emit()
	print("【场景】切换完成!")


func _set_dissolve(value: float) -> void:
	_shader_material.set_shader_parameter("dissolve", value)


func _apply_camera_config(area_id: String) -> void:
	await get_tree().process_frame
	var camera = get_viewport().get_camera_2d()
	if not camera:
		print("【场景】警告：找不到 Camera2D")
		return

	var config = CAMERA_CONFIGS.get(area_id, {})
	var target_zoom = config.get("zoom", 1.0)
	print("【场景】应用镜头缩放: ", target_zoom)

	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(target_zoom, target_zoom), 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func is_transitioning() -> bool:
	return _is_transitioning
