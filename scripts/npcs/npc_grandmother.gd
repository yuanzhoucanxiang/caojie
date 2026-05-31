## 职责：外婆NPC——定义外婆的专属事件数据（童年首周事件链）
extends NPCBase

func _ready() -> void:
	npc_id = "grandmother"
	npc_name = "外婆"
	sprite_color = Color(0.933, 0.533, 0.6, 1)
	npc_body_size = Vector2(42, 78)
	prompt_offset_y = 90.0
	default_text = "乖孙，今天没有特别的事。去找点事做吧。"
	default_expression = "normal"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		# —— 首周主线 ——
		{
			"id": "w1_gm_arrival",
			"conditions": [],
			"text": "乖孙，到了啊。这里是外婆家，以后就是你的家了。院子里到处可以走走，但别跑太远。",
			"expression": "smile",
			"choices": [
				{"text": "我记住了，外婆。", "effects": {"懂事": 1, "亲密": 1}},
				{"text": "我想先看看院子！", "effects": {"好奇": 1}}
			]
		},
		{
			"id": "w1_gm_feed_chickens_task",
			"conditions": ["event_completed:w1_gm_arrival"],
			"text": "乖孙，院子里的鸡还没喂呢。你去左边鸡棚那儿，抓一把谷糠撒在地上就行。小心别踩到鸡食盆。",
			"expression": "normal",
			"choices": [
				{"text": "我去试试！", "effects": {"勤劳": 1}},
				{"text": "鸡会不会啄我啊？", "effects": {"亲密": 1}}
			]
		},
		{
			"id": "w1_gm_feed_chickens_return",
			"conditions": ["event_completed:w1_act_feed_chickens"],
			"text": "哎呀，乖孙会喂鸡了。以后你就是家里的一份子啦。",
			"expression": "smile",
			"choices": [
				{"text": "下次我还喂！", "effects": {"亲密": 1, "勤劳": 1}},
				{"text": "它们好吵啊。", "effects": {"好奇": 1}}
			]
		},
		{
			"id": "w1_gm_homesick_evening",
			"conditions": [
				"event_completed:w1_at_water_return",
				"event_completed:w1_xm_friend_return"
			],
			"text": "天快黑了。想妈妈了吧？没事的，外婆在呢。",
			"expression": "kind",
			"choices": [
				{"text": "我有点想妈妈……", "effects": {"亲密": 1}},
				{"text": "我在这里也可以的。", "effects": {"懂事": 1, "亲密": 1}}
			]
		},
		# —— 日常（repeatable 放最后）——
		{
			"id": "w1_gm_daily_repeat",
			"conditions": ["event_completed:w1_gm_homesick_evening"],
			"text": "乖孙，今天想去哪儿玩？外婆给你留了红薯。",
			"expression": "smile",
			"choices": [
				{"text": "谢谢外婆！", "effects": {}},
				{"text": "我想去院子里。", "effects": {}}
			],
			"repeatable": true
		},
	]
