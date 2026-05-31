## 职责：舅妈NPC——定义舅妈的专属事件数据（童年首周事件链）
extends NPCBase

func _ready() -> void:
	npc_id = "aunt"
	npc_name = "舅妈"
	sprite_color = Color(0.8, 0.6, 0.3, 1)
	npc_body_size = Vector2(40, 82)
	prompt_offset_y = 94.0
	default_text = "在忙呢，等会儿吃饭。"
	default_expression = "normal"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		# —— 首周主线 ——
		{
			"id": "w1_at_kitchen_greeting",
			"conditions": ["event_completed:w1_gm_arrival"],
			"text": "饿了吧？先吃点东西，这是舅妈做的饭。吃完记得把碗放灶台上。",
			"expression": "kind",
			"choices": [
				{"text": "谢谢舅妈！", "effects": {"懂事": 1, "亲密": 1}},
				{"text": "我还不饿……", "effects": {}}
			]
		},
		{
			"id": "w1_at_water_task",
			"conditions": ["event_completed:w1_at_kitchen_greeting"],
			"text": "你去井边看看水桶装满没有，要是满了就提回来。小心地滑。",
			"expression": "normal",
			"choices": [
				{"text": "我去！", "effects": {"勤劳": 1}},
				{"text": "我怕滑倒……", "effects": {"懂事": 1}}
			]
		},
		{
			"id": "w1_at_water_return",
			"conditions": ["event_completed:w1_act_fetch_water"],
			"text": "不错嘛。在乡下做事要慢一点，别着急，习惯就好。",
			"expression": "kind",
			"choices": [
				{"text": "我会小心的。", "effects": {"懂事": 1, "亲密": 1}},
				{"text": "我力气还可以吧！", "effects": {"体力": 1}}
			]
		},
		# —— 日常（repeatable 放最后）——
		{
			"id": "w1_at_daily_repeat",
			"conditions": ["event_completed:w1_at_water_return"],
			"text": "饿了就来找舅妈，灶上总有东西热着。",
			"expression": "kind",
			"choices": [
				{"text": "谢谢舅妈！", "effects": {}},
				{"text": "好的。", "effects": {}}
			],
			"repeatable": true
		},
	]
