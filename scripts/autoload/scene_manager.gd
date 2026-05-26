## 职责：场景切换管理——推拉幕布过渡动画、室内外镜头切换
extends Node

signal transition_completed

const CAMERA_CONFIGS = {
	"courtyard": {
		"zoom": 1.25,
		"offset": Vector2(0, -100),
		"player_bounds": {"left": 32, "right": 1680, "top": 360, "bottom": 520},
	},
	"house_floor1": {
		"zoom": 1.8,
		"offset": Vector2(0, 0),
		"limits": {"left": 0, "right": 750, "top": 0, "bottom": 480},
		"player_bounds": {"left": 20, "right": 730, "top": 350, "bottom": 400},
	},
	"house_floor2": {
		"zoom": 1.8,
		"offset": Vector2(0, 0),
		"limits": {"left": 0, "right": 640, "top": 0, "bottom": 480},
		"player_bounds": {"left": 16, "right": 624, "top": 50, "bottom": 450},
	},
	"house_floor3": {
		"zoom": 2.0,
		"offset": Vector2(0, 0),
		"limits": {"left": 0, "right": 510, "top": 0, "bottom": 480},
		"player_bounds": {"left": 20, "right": 490, "top": 330, "bottom": 400},
	},
	"village_road": {
		"zoom": 0.9,
		"offset": Vector2(0, -100),
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
	transition_color: Color = Color(0, 0, 0, 1),
	spawn_id: String = "",
) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_pending_spawn = spawn_id

	var vs := get_viewport().get_visible_rect().size

	# ——— 幕布就位（屏幕左侧外） ———
	_curtain.size = vs
	_curtain.color = Color(transition_color.r * 0.35, transition_color.g * 0.32, transition_color.b * 0.28, 1.0)
	_curtain.position = Vector2(-vs.x, 0)
	_curtain.visible = true

	# ——— 第一次滑动：从左边滑入 ———
	var t_in := create_tween()
	t_in.tween_property(_curtain, "position:x", 0.0, 0.3) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await t_in.finished

	# ——— 切场景 ———
	var new_instance := packed_scene.instantiate()
	var old := get_tree().current_scene
	if old:
		get_tree().root.remove_child(old)
		old.queue_free()
	get_tree().root.add_child(new_instance)
	get_tree().current_scene = new_instance
	_current_area = area_id
	AudioManager.play_sfx("SFX/door_open.ogg")

	await get_tree().process_frame
	_setup_area(area_id)
	await get_tree().process_frame
	await get_tree().process_frame

	# ——— 第二次滑动：往右滑出 ———
	var t_out := create_tween()
	t_out.tween_property(_curtain, "position:x", vs.x, 0.3) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await t_out.finished

	# ——— 收尾 ———
	_curtain.visible = false
	_is_transitioning = false
	transition_completed.emit()


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
			var L: Dictionary = config["limits"]
			camera.limit_left = L.get("left", -10000000)
			camera.limit_right = L.get("right", 10000000)
			camera.limit_top = L.get("top", -10000000)
			camera.limit_bottom = L.get("bottom", 10000000)

	if config.has("player_bounds"):
		var b: Dictionary = config["player_bounds"]
		var oy: float = config.get("offset", Vector2.ZERO).y
		var p = get_tree().get_first_node_in_group("player")
		if p and p.has_method("set_movement_bounds"):
			p.set_movement_bounds(b["left"], b["right"], b["top"], b["bottom"], oy)


func get_current_area() -> String:
	return _current_area


func get_pending_spawn() -> String:
	var id := _pending_spawn
	_pending_spawn = ""
	return id


func is_transitioning() -> bool:
	return _is_transitioning
