## 职责：场景切换管理——全屏过渡动画、室内外镜头切换
## 谁使用它：场景边界触发器（Area2D）、Main
## 它使用谁：无（通过场景树操作）

extends Node

signal transition_completed

var _overlay: ColorRect
var _is_transitioning: bool = false

## 不同区域的镜头配置
const CAMERA_CONFIGS = {
	"courtyard": {"zoom": 1.0},
	"house_floor1": {"zoom": 1.5},
	"house_floor2": {"zoom": 1.5},
	"house_floor3": {"zoom": 1.8},
	"village_road": {"zoom": 0.9},
}

var _current_area: String = "courtyard"


func _ready() -> void:
	# 创建全屏黑色遮罩（初始透明）
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 加到最高层
	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.add_child(_overlay)
	add_child(layer)
	# 初始大小
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)


func change_scene(scene_path: String, area_id: String = "courtyard", transition_color: Color = Color(0, 0, 0, 1)) -> void:
	print("【场景】change_scene 被调用: ", scene_path, " 区域: ", area_id)
	if _is_transitioning:
		print("【场景】正在过渡中，忽略")
		return
	_is_transitioning = true

	# 淡出（覆盖全屏）
	_overlay.color = Color(transition_color.r, transition_color.g, transition_color.b, 0)
	var tween_out = create_tween()
	tween_out.tween_property(_overlay, "color:a", 1.0, 0.4).set_ease(Tween.EASE_IN)
	await tween_out.finished

	# 切换场景
	get_tree().change_scene_to_file(scene_path)
	# 等待新场景加载完成
	await get_tree().process_frame
	await get_tree().process_frame

	# 应用镜头配置
	_apply_camera_config(area_id)
	_current_area = area_id

	# 淡入
	var tween_in = create_tween()
	tween_in.tween_property(_overlay, "color:a", 0.0, 0.4).set_ease(Tween.EASE_OUT)
	await tween_in.finished

	# 确保遮罩完全透明且不阻挡输入
	_overlay.color = Color(0, 0, 0, 0)

	_is_transitioning = false
	transition_completed.emit()


func _apply_camera_config(area_id: String) -> void:
	await get_tree().process_frame
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var config = CAMERA_CONFIGS.get(area_id, {})
	var target_zoom = config.get("zoom", 1.0)

	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(target_zoom, target_zoom), 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func is_transitioning() -> bool:
	return _is_transitioning
