extends GdUnitTestSuite

## NPC 事件选择回归测试
## 验证已完成的非 repeatable 事件被跳过，repeatable 日常不抢主线


func before_test() -> void:
	GameState.reset()


## 完成第一条事件后应进入第二条事件
func test_completed_one_shot_event_is_skipped() -> void:
	var npc: NPCBase = auto_free(load("res://scripts/npcs/npc_grandmother.gd").new())

	GameState.complete_event("w1_gm_arrival")
	var event: Dictionary = npc._get_available_event()

	assert_that(event.get("id", "")).is_equal("w1_gm_feed_chickens_task")


## repeatable 日常在主线未完成时不出现
func test_daily_not_before_mainline() -> void:
	var npc: NPCBase = auto_free(load("res://scripts/npcs/npc_grandmother.gd").new())

	# 只完成 arrival，daily 需要 homesick_evening 完成
	GameState.complete_event("w1_gm_arrival")
	var event: Dictionary = npc._get_available_event()

	assert_that(event.get("id", "")).is_equal("w1_gm_feed_chickens_task")
