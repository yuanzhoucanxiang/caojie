## 职责：交互聚焦选择器——在多个重叠触发点中选出唯一响应者
## 谁使用它：NPCBase、InteractableObject、TransitionTrigger
## 它使用谁：场景树分组、Player 位置、各交互源暴露的范围/优先级方法

class_name InteractionFocus
extends RefCounted

const GROUP_NAME := "interaction_candidates"


static func register(candidate: Node) -> void:
	candidate.add_to_group(GROUP_NAME)


static func is_focused(candidate: Node) -> bool:
	if DialogueManager.is_dialogue_active():
		return false
	var tree := candidate.get_tree()
	if tree == null:
		return true
	var player := tree.get_first_node_in_group("player") as Node2D
	var player_pos := player.global_position if player else _get_anchor(candidate)
	return get_focused_candidate(tree, player_pos) == candidate


static func get_focused_candidate(tree: SceneTree, player_pos: Vector2) -> Node:
	var best: Node = null
	var best_priority := -999999
	var best_distance := INF
	var best_y := -INF

	for candidate in tree.get_nodes_in_group(GROUP_NAME):
		if not is_instance_valid(candidate):
			continue
		if not candidate.has_method("is_player_in_interaction_range"):
			continue
		if not candidate.is_player_in_interaction_range():
			continue

		var priority := _get_priority(candidate)
		var anchor := _get_anchor(candidate)
		var distance := anchor.distance_squared_to(player_pos)
		var y := anchor.y

		if _is_better(priority, distance, y, best_priority, best_distance, best_y):
			best = candidate
			best_priority = priority
			best_distance = distance
			best_y = y

	return best


static func _is_better(
	priority: int,
	distance: float,
	y: float,
	best_priority: int,
	best_distance: float,
	best_y: float,
) -> bool:
	if priority != best_priority:
		return priority > best_priority
	if not is_equal_approx(distance, best_distance):
		return distance < best_distance
	return y > best_y


static func _get_priority(candidate: Node) -> int:
	if candidate.has_method("get_interaction_priority"):
		return candidate.get_interaction_priority()
	return 0


static func _get_anchor(candidate: Node) -> Vector2:
	if candidate.has_method("get_interaction_anchor"):
		return candidate.get_interaction_anchor()
	var node_2d := candidate as Node2D
	return node_2d.global_position if node_2d else Vector2.ZERO
