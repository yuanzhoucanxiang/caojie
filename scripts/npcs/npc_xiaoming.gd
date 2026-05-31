## 职责：小明NPC——定义小明的专属事件数据（童年首周事件链）
extends NPCBase

func _ready() -> void:
	npc_id = "xiaoming"
	npc_name = "小明"
	sprite_color = Color(0.7, 0.55, 0.35, 1)
	npc_body_size = Vector2(34, 60)
	prompt_offset_y = 72.0
	default_text = "走不走？我带你去个好玩的地方！"
	default_expression = "grin"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		# —— 首周主线 ——
		{
			"id": "w1_xm_first_meet",
			"conditions": ["event_completed:w1_gm_arrival"],
			"text": "哎！你是新来的吧？我叫亚明，大家都叫我小明！我家就在那边。",
			"expression": "grin",
			"choices": [
				{"text": "我叫___，我叫你一起玩好吗？", "effects": {"亲密": 1, "好奇": 1}},
				{"text": "（点点头）", "effects": {"懂事": 1}}
			]
		},
		{
			"id": "w1_xm_clothesline_task",
			"conditions": ["event_completed:w1_xm_first_meet"],
			"text": "你看那边晾衣绳，衣服快掉了！我们去扶一下吧？",
			"expression": "normal",
			"choices": [
				{"text": "我们一起扶好！", "effects": {"亲密": 1, "勤劳": 1}},
				{"text": "我去叫大人。", "effects": {"懂事": 1}}
			]
		},
		{
			"id": "w1_xm_friend_return",
			"conditions": ["event_completed:w1_act_collect_clothes"],
			"text": "你人不错嘛！以后我们就是朋友了，有什么事可以找我。",
			"expression": "grin",
			"choices": [
				{"text": "明天还一起玩吗？", "effects": {"亲密": 1}},
				{"text": "我还想看看村口那边。", "effects": {"好奇": 1}}
			]
		},
		# —— 日常（repeatable 放最后）——
		{
			"id": "w1_xm_daily_repeat",
			"conditions": ["event_completed:w1_xm_friend_return"],
			"text": "走不走？今天去哪玩？",
			"expression": "grin",
			"choices": [
				{"text": "等一下！", "effects": {}},
				{"text": "你自己先去吧。", "effects": {}}
			],
			"repeatable": true
		},
	]
