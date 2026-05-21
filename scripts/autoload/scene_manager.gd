## 职责：场景切换管理——全屏过渡动画、室内外镜头切换
## 谁使用它：场景边界触发器（StaticBody2D）
## 它使用谁：无（通过场景树操作）

extends Node

signal transition_completed

var _overlay: ColorRect
var _is_transitioning: bool = false

const CAMERA_CONFIGS = {
	"courtyard": {"zoom": 1.0},
	"house_floor1": {"zoom": 1.5},
	"house_floor2": {"zoom": 1.5},
	"house_floor3": {"zoom": 1.8},
	"village_road": {"zoom": 0.9},
}

var _current_area: String = "courtyard"


func _ready() -> void:
	# 创建全屏遮罩
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.z_index = 4096
	add_child(_overlay)


func _process(_delta: float) -> void:
	# 确保遮罩始终覆盖全屏
	if _overlay and is_instance_valid(_overlay):
		var viewport_size = get_viewport().get_visible_rect().size
		_overlay.size = viewport_size


func change_scene(scene_path: String, area_id: String = "courtyard", transition_color: Color = Color(0, 0, 0, 1)) -> void:
	print("【场景】开始切换到: ", scene_path)
	if _is_transitioning:
		print("【场景】正在过渡中，忽略")
		return
	_is_transitioning = true

	# 遮罩变黑
	_overlay.color = transition_color
	print("【场景】遮罩已变黑，alpha: ", _overlay.color.a)

	# 直接切换（不用 await，避免时序问题）
	var packed_scene = load(scene_path) as PackedScene
	if packed_scene == null:
		print("【场景】错误：无法加载 ", scene_path)
		_overlay.color = Color(0, 0, 0, 0)
		_is_transitioning = false
		return

	print("【场景】场景加载成功，实例化中...")
	var new_instance = packed_scene.instantiate()

	# 移除旧场景
	var old = get_tree().current_scene
	if old:
		get_tree().root.remove_child(old)
		old.queue_free()

	# 添加新场景
	get_tree().root.add_child(new_instance)
	get_tree().current_scene = new_instance
	_current_area = area_id
	print("【场景】新场景已就位: ", new_instance.name)

	# 等一帧后开始淡入
	await get_tree().process_frame
	_apply_camera_config(area_id)

	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 0.0, 0.4)
	await tween.finished

	_overlay.color = Color(0, 0, 0, 0)
	_is_transitioning = false
	transition_completed.emit()
	print("【场景】切换完成!")


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
