## 职责：场景切换管理——推拉幕布过渡动画、室内外镜头切换
extends Node

signal transition_completed

const CAMERA_CONFIGS = {
	"courtyard": {
		"zoom": 1.25,
		"offset": Vector2(0, -150),
		"allow_zoom": true,
		"depth_scale": {"min": 0.78, "max": 1.08},
		"player_bounds": {"left": 32, "right": 1680, "top": 350, "bottom": 520},
	},
	"house_floor1": {
		"zoom": 1.8,
		"offset": Vector2(0, 0),
		"allow_zoom": false,
		"depth_scale": {"min": 0.9, "max": 1.05},
		"limits": {"left": 0, "right": 750, "top": 0, "bottom": 480},
		"player_bounds": {"left": 30, "right": 720, "top": 350, "bottom": 400},
	},
	"house_floor2": {
		"zoom": 1.8,
		"offset": Vector2(0, 0),
		"allow_zoom": false,
		"depth_scale": {"min": 0.9, "max": 1.05},
		"limits": {"left": 0, "right": 640, "top": 0, "bottom": 480},
		"player_bounds": {"left": 30, "right": 610, "top": 350, "bottom": 400},
	},
	"house_floor3": {
		"zoom": 2.0,
		"offset": Vector2(0, -40),
		"allow_zoom": false,
		"depth_scale": {"min": 0.9, "max": 1.05},
		"limits": {"left": 0, "right": 510, "top": 0, "bottom": 480},
		"player_bounds": {"left": 30, "right": 480, "top": 340, "bottom": 400},
	},
	"village_road": {
		"zoom": 0.9,
		"offset": Vector2(0, -100),
		"allow_zoom": true,
		"depth_scale": {"min": 0.85, "max": 1.0},
		"player_bounds": {"left": 32, "right": 1680, "top": 360, "bottom": 520},
	},
}

var _curtain: ColorRect
var _is_transitioning: bool = false
var _current_area: String = "courtyard"
var _pending_spawn: String = ""


func _ready() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 128
	add_child(canvas)

	_curtain = ColorRect.new()
	_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.visible = false
	canvas.add_child(_curtain)


func _exit_tree() -> void:
	if _curtain:
		_curtain.queue_free()


func change_to_packed(
	packed_scene: PackedScene,
	area_id: String = "courtyard",
	transition_color: Color = Color(0.08, 0.06, 0.04, 1),
	spawn_id: String = "",
) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_pending_spawn = spawn_id

	var vs := get_viewport().get_visible_rect().size

	# ——— 幕布就位（屏幕左侧外） ———
	_curtain.size = vs
	var tc := transition_color
	_curtain.color = Color(tc.r * 0.35, tc.g * 0.32, tc.b * 0.28, 1.0)
	_curtain.position = Vector2(-vs.x, 0)
	_curtain.visible = true

	# ——— 第一次滑动：从左边滑入 ———
	print("【切换】滑入开始 → ", area_id)
	var t_in := create_tween()
	t_in.tween_property(_curtain, "position:x", 0.0, 0.3) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await t_in.finished

	# ——— 切场景 ———
	print("【切换】幕布遮住，开始切场景")
	var new_instance := packed_scene.instantiate()
	var old := get_tree().current_scene
	if old:
		get_tree().root.remove_child(old)
		old.queue_free()
	get_tree().root.add_child(new_instance)
	get_tree().current_scene = new_instance
	_current_area = area_id
	AudioManager.play_sfx("SFX/door_open.ogg")
	print("【切换】新场景已就位: ", new_instance.name)

	await get_tree().process_frame
	print("【切换】等一帧完成，设镜头")
	_setup_area(area_id)
	print("【切换】镜头设完，等渲染")
	await get_tree().process_frame
	await get_tree().process_frame
	print("【切换】渲染等完，准备滑出")

	# ——— 第二次滑动：往右滑出 ———
	var t_out := create_tween()
	t_out.tween_property(_curtain, "position:x", vs.x, 0.3) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await t_out.finished
	print("【切换】滑出完成")

	# ——— 收尾 ———
	_curtain.visible = false
	_is_transitioning = false
	transition_completed.emit()
	print("【切换】过渡结束!")


func _setup_area(area_id: String) -> void:
	var config: Dictionary = CAMERA_CONFIGS.get(area_id, {})
	var camera := get_viewport().get_camera_2d()
	if camera:
		var z: float = config.get("zoom", 1.0)
		camera.zoom = Vector2(z, z)
		if config.has("offset"):
			camera.position = config["offset"]
		camera.reset_smoothing()
		if config.has("limits"):
			var lim: Dictionary = config["limits"]
			camera.limit_left = lim.get("left", -10000000)
			camera.limit_right = lim.get("right", 10000000)
			camera.limit_top = lim.get("top", -10000000)
			camera.limit_bottom = lim.get("bottom", 10000000)

	if config.has("player_bounds"):
		var b: Dictionary = config["player_bounds"]
		var oy: float = config.get("offset", Vector2.ZERO).y
		var p = get_tree().get_first_node_in_group("player")
		if p and p.has_method("set_movement_bounds"):
			p.set_movement_bounds(b["left"], b["right"], b["top"], b["bottom"], oy)


func get_current_area() -> String:
	return _current_area


func can_zoom_current_area() -> bool:
	return CAMERA_CONFIGS.get(_current_area, {}).get("allow_zoom", false)


func get_current_depth_scale() -> Dictionary:
	return CAMERA_CONFIGS.get(_current_area, {}).get("depth_scale", {})


func get_pending_spawn() -> String:
	var id := _pending_spawn
	_pending_spawn = ""
	return id


func is_transitioning() -> bool:
	return _is_transitioning
