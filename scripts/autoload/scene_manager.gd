## 职责：场景切换管理——推拉幕布过渡动画、室内外镜头切换
## 谁使用它：场景边界触发器（StaticBody2D）
## 它使用谁：无外部依赖

extends Node

signal transition_completed

const CAMERA_CONFIGS = {
	"courtyard": {"zoom": 1.25},
	"house_floor1": {"zoom": 1.5},
	"house_floor2": {"zoom": 1.5},
	"house_floor3": {"zoom": 1.8},
	"village_road": {"zoom": 0.9},
}

var _curtain: ColorRect
var _is_transitioning: bool = false
var _current_area: String = "courtyard"
var _pending_spawn: String = ""


func _ready() -> void:
	_curtain = ColorRect.new()
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.z_index = 4096
	add_child(_curtain)
	# 初始藏在屏幕左侧外
	_reset_curtain()


func _reset_curtain() -> void:
	var vs := get_viewport().get_visible_rect().size
	_curtain.size = vs
	_curtain.position = Vector2(-vs.x, 0)


func _process(_delta: float) -> void:
	if _curtain and is_instance_valid(_curtain):
		var vs := get_viewport().get_visible_rect().size
		_curtain.size = vs


func change_to_packed(
	packed_scene: PackedScene,
	area_id: String = "courtyard",
	transition_color: Color = Color(0, 0, 0, 1),
	spawn_id: String = "",
) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_pending_spawn = spawn_id

	# 暗沉版场景主色调
	_curtain.color = Color(
		transition_color.r * 0.35,
		transition_color.g * 0.32,
		transition_color.b * 0.28,
		1.0,
	)

	var vs := get_viewport().get_visible_rect().size
	_curtain.position = Vector2(-vs.x, 0)

	# 幕布从左边滑入
	var t_in := create_tween()
	t_in.tween_property(_curtain, "position:x", 0.0, 0.3) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await t_in.finished

	# 遮住时：切场景 + 设镜头
	var new_instance := packed_scene.instantiate()
	var old := get_tree().current_scene
	if old:
		get_tree().root.remove_child(old)
		old.queue_free()
	get_tree().root.add_child(new_instance)
	get_tree().current_scene = new_instance
	_current_area = area_id
	print("【场景】新场景已就位: ", new_instance.name)

	await get_tree().process_frame
	_set_camera_zoom(area_id)

	# 幕布往右滑出
	var vs2 := get_viewport().get_visible_rect().size
	var t_out := create_tween()
	t_out.tween_property(_curtain, "position:x", vs2.x, 0.3) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await t_out.finished

	_reset_curtain()
	_is_transitioning = false
	transition_completed.emit()
	print("【场景】切换完成!")


func _set_camera_zoom(area_id: String) -> void:
	var camera := get_viewport().get_camera_2d()
	if not camera:
		return
	var config: Dictionary = CAMERA_CONFIGS.get(area_id, {})
	var target_zoom: float = config.get("zoom", 1.0)
	camera.zoom = Vector2(target_zoom, target_zoom)


func get_current_area() -> String:
	return _current_area


func get_pending_spawn() -> String:
	var id := _pending_spawn
	_pending_spawn = ""
	return id


func is_transitioning() -> bool:
	return _is_transitioning
