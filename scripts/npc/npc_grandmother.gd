## 职责：外婆NPC——定义外婆的专属事件数据
extends NPCBase

func _ready() -> void:
	npc_id = "grandmother"
	npc_name = "外婆"
	sprite_color = Color(0.933, 0.533, 0.6, 1)
	default_text = "乖孙，今天没有特别的事。去找点事做吧。"
	default_expression = "normal"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		{
			"id": "gm_event_1",
			"conditions": [],
			"text": "乖孙，过来帮外婆择菜。",
			"expression": "smile",
			"choices": [
				{"text": "好的外婆！", "effects": {"懂事": 1, "亲密": 1}},
				{"text": "我想出去玩...", "effects": {"好奇": 1, "亲密": -1}}
			]
		},
		{
			"id": "gm_event_2",
			"conditions": ["event_completed:gm_event_1"],
			"text": "来，外婆给你讲个故事。从前啊……",
			"expression": "smile",
			"choices": [
				{"text": "认真听外婆讲", "effects": {"懂事": 1, "亲密": 1}},
				{"text": "追着问各种问题", "effects": {"好奇": 1, "勤劳": -1}}
			]
		},
		{
			"id": "gm_event_3",
			"conditions": ["event_completed:gm_event_2"],
			"text": "院子的菜该浇水了，你要不要来试试？",
			"expression": "normal",
			"choices": [
				{"text": "积极帮忙！", "effects": {"勤劳": 1, "体力": 1, "亲密": 1}},
				{"text": "装作没听见……", "effects": {"懂事": -1}}
			]
		}
	]
