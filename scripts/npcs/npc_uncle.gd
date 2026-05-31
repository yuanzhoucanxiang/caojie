## 职责：舅舅NPC——定义舅舅的专属事件数据（童年首周事件链）
extends NPCBase

func _ready() -> void:
	npc_id = "uncle"
	npc_name = "舅舅"
	sprite_color = Color(0.6, 0.5, 0.4, 1)
	npc_body_size = Vector2(42, 84)
	prompt_offset_y = 96.0
	default_text = "（舅舅看了你一眼，没说话，继续抽烟。）"
	default_expression = "tired"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		# —— 首周主线 ——
		{
			"id": "w1_uc_first_greeting",
			"conditions": ["event_completed:w1_gm_arrival"],
			"text": "来了啊。",
			"expression": "tired",
			"choices": [
				{"text": "舅舅好。", "effects": {"懂事": 1}},
				{"text": "（躲到外婆身后）", "effects": {"亲密": 1}}
			]
		},
		{
			"id": "w1_uc_scooter_hint",
			"conditions": ["event_completed:w1_uc_first_greeting"],
			"text": "那摩托车是舅舅的，你别乱碰。看看可以，别爬上去。",
			"expression": "tired",
			"choices": [
				{"text": "我就看看。", "effects": {"懂事": 1}},
				{"text": "它能骑多快？", "effects": {"好奇": 1}}
			]
		},
		{
			"id": "w1_uc_softened",
			"conditions": [
				"event_completed:w1_act_check_scooter",
				"event_completed:w1_gm_feed_chickens_return"
			],
			"text": "听外婆说你帮忙喂鸡了？嗯……院子里的事，多做一点是好事。",
			"expression": "normal",
			"choices": [
				{"text": "我有帮忙的！", "effects": {"勤劳": 1}},
				{"text": "外婆让我别跑太远。", "effects": {"懂事": 1}}
			]
		},
		# —— 日常（repeatable 放最后）——
		{
			"id": "w1_uc_daily_repeat",
			"conditions": ["event_completed:w1_uc_softened"],
			"text": "（舅舅点点头，没说话。）",
			"expression": "tired",
			"choices": [
				{"text": "（安静走开）", "effects": {}}
			],
			"repeatable": true
		},
	]
