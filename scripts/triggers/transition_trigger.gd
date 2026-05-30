## 职责：场景切换触发器——玩家靠近时显示提示，按E触发场景切换
extends StaticBody2D

const InteractionFocusScript := preload("res://scripts/triggers/interaction_focus.gd")

@export var target_scene_path: String = ""
@export var target_area_id: String = "courtyard"
@export var transition_color: Color = Color(0.95, 0.93, 0.88)
@export var prompt_text: String = "按 E 进入"
@export var spawn_id: String = ""
@export var interaction_priority: int = 10

var _in_range: bool = false
var _packed_scene: PackedScene = null

@onready var trigger_zone: Area2D = $TriggerZone


func _draw() -> void:
	if _in_range and InteractionFocusScript.is_focused(self):
		var font: Font = ThemeDB.fallback_font
		draw_string(font, Vector2(-40, -60), prompt_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)


func _ready() -> void:
	InteractionFocusScript.register(self)
	# 预加载目标场景
	if target_scene_path != "":
		_packed_scene = load(target_scene_path) as PackedScene
		if _packed_scene == null:
			print("【门】错误：无法加载 ", target_scene_path)
		else:
			print("【门】加载成功: ", target_scene_path)

	trigger_zone.area_entered.connect(_on_area_entered)
	trigger_zone.area_exited.connect(_on_area_exited)
	_register_to_player()


func _register_to_player() -> void:
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("interact_pressed"):
		player.interact_pressed.connect(_on_player_interact)


func _on_player_interact() -> void:
	if DialogueManager.is_dialogue_active():
		return
	if not InteractionFocusScript.is_focused(self):
		return
	if _in_range and not SceneManager.is_transitioning():
		if _packed_scene != null:
			SceneManager.change_to_packed(
				_packed_scene, target_area_id, transition_color, spawn_id,
			)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = true
		queue_redraw()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		_in_range = false
		queue_redraw()


func _process(_delta: float) -> void:
	if _in_range:
		queue_redraw()


func is_player_in_interaction_range() -> bool:
	return _in_range


func get_interaction_priority() -> int:
	return interaction_priority


func get_interaction_anchor() -> Vector2:
	return global_position
