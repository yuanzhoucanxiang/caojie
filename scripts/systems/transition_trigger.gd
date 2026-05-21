## 职责：场景切换触发器——玩家走进 Area2D 时触发场景切换
## 谁使用它：挂载到场景边界的 Area2D 节点上
## 它使用谁：SceneManager

extends Area2D

@export var target_scene: String = ""
@export var target_area_id: String = "courtyard"
@export var transition_color: Color = Color(0.95, 0.93, 0.88)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not SceneManager.is_transitioning():
		if target_scene != "":
			SceneManager.change_scene(target_scene, target_area_id, transition_color)
