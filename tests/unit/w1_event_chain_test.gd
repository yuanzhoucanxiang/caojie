extends GdUnitTestSuite

## 童年首周事件链回归测试
## 验证 w1_ 事件 ID 唯一性、条件推进、repeatable 不抢主线


func before_test() -> void:
	GameState.reset()


## 所有 w1_ 事件 ID 必须唯一
func test_w1_event_ids_unique() -> void:
	var all_ids: Array[String] = []
	var npcs: Array[NPCBase] = [
		load("res://scripts/npcs/npc_grandmother.gd").new(),
		load("res://scripts/npcs/npc_uncle.gd").new(),
		load("res://scripts/npcs/npc_aunt.gd").new(),
		load("res://scripts/npcs/npc_cousin2.gd").new(),
		load("res://scripts/npcs/npc_xiaoming.gd").new(),
	]
	for npc in npcs:
		auto_free(npc)
		var events: Array[Dictionary] = npc._get_events()
		for ev in events:
			var eid: String = ev.get("id", "")
			if eid.begins_with("w1_"):
				assert_that(all_ids).not_contains(eid)
				all_ids.append(eid)


## 外婆 arrival 事件无条件触发
func test_grandmother_arrival_no_condition() -> void:
	var npc: NPCBase = auto_free(load("res://scripts/npcs/npc_grandmother.gd").new())
	var event: Dictionary = npc._get_available_event()
	assert_that(event.get("id", "")).is_equal("w1_gm_arrival")


## 完成 arrival 后触发 feed_chickens_task
func test_grandmother_after_arrival() -> void:
	var npc: NPCBase = auto_free(load("res://scripts/npcs/npc_grandmother.gd").new())
	GameState.complete_event("w1_gm_arrival")
	var event: Dictionary = npc._get_available_event()
	assert_that(event.get("id", "")).is_equal("w1_gm_feed_chickens_task")


## 非 repeatable 事件完成后跳过
func test_onetime_event_skipped_after_complete() -> void:
	var npc: NPCBase = auto_free(load("res://scripts/npcs/npc_grandmother.gd").new())
	GameState.complete_event("w1_gm_arrival")
	GameState.complete_event("w1_gm_feed_chickens_task")
	GameState.complete_event("w1_act_feed_chickens")
	GameState.complete_event("w1_gm_feed_chickens_return")
	var event: Dictionary = npc._get_available_event()
	# 前四个完成但 homesick 条件不满足（需要 water_return + friend_return），应该返回空
	assert_that(event.get("id", "")).is_equal("")


## repeatable 日常不抢主线
func test_daily_not_before_mainline() -> void:
	var npc: NPCBase = auto_free(load("res://scripts/npcs/npc_grandmother.gd").new())
	# 只完成 arrival，daily 需要 homesick_evening，不应该出现
	GameState.complete_event("w1_gm_arrival")
	var event: Dictionary = npc._get_available_event()
	assert_that(event.get("id", "")).is_equal("w1_gm_feed_chickens_task")


## InteractableObject 行动事件条件不满足时不触发
func test_interactable_condition_gated() -> void:
	var obj: InteractableObject = auto_free(InteractableObject.new())
	obj.event_id = "w1_act_feed_chickens"
	obj.event_text = "喂鸡"
	obj.event_conditions = ["event_completed:w1_gm_feed_chickens_task"]
	# 条件不满足，不应发出事件
	var triggered := false
	obj.dialogue_request.connect(func(_n, _d): triggered = true)
	obj._try_action_event()
	assert_that(triggered).is_false()


## InteractableObject 条件满足时触发事件
func test_interactable_condition_met() -> void:
	var obj: InteractableObject = auto_free(InteractableObject.new())
	obj.event_id = "w1_act_feed_chickens"
	obj.event_text = "喂鸡"
	obj.event_conditions = ["event_completed:w1_gm_feed_chickens_task"]
	GameState.complete_event("w1_gm_feed_chickens_task")
	var received_id := ""
	obj.dialogue_request.connect(func(_n, d): received_id = d.get("id", ""))
	obj._try_action_event()
	assert_that(received_id).is_equal("w1_act_feed_chickens")
