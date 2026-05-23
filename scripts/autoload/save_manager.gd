## 职责：存档/读档——JSON 序列化游戏状态到 user:// 文件
## 谁使用它：暂停菜单、标题界面、玩家
## 它使用谁：GameState、SceneManager

extends Node

const SAVE_PATH := "user://save_001.json"

const SCENE_MAP := {
	"courtyard": "res://scenes/main.tscn",
	"house_floor1": "res://scenes/areas/house_floor1.tscn",
	"house_floor2": "res://scenes/areas/house_floor2.tscn",
	"house_floor3": "res://scenes/areas/house_floor3.tscn",
}

var _pending_position: Vector2 = Vector2.ZERO
var _has_pending: bool = false


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(player_pos: Vector2, area_id: String) -> void:
	var data := {
		"player_x": player_pos.x,
		"player_y": player_pos.y,
		"scene": area_id,
		"attributes": GameState.attributes,
		"completed_events": GameState.completed_events,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	print("【存档】已保存")


func load_and_transition() -> void:
	if not has_save():
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_as_text())
	var data: Dictionary = json.get_data()

	GameState.attributes = data["attributes"]
	GameState.completed_events.clear()
	for event_id: String in data["completed_events"]:
		GameState.completed_events.append(event_id)

	_pending_position = Vector2(data["player_x"], data["player_y"])
	_has_pending = true

	var area_id: String = data["scene"]
	var scene_path: String = SCENE_MAP.get(area_id, SCENE_MAP["courtyard"])
	SceneManager.change_to_packed(
		load(scene_path), area_id, Color(0.3, 0.25, 0.18),
	)


func apply_position(player: CharacterBody2D) -> void:
	if _has_pending:
		player.position = _pending_position
		_has_pending = false
		print("【存档】已恢复玩家位置: ", _pending_position)
