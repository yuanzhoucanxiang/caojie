## 职责：二表哥NPC——定义二表哥的专属事件数据
extends NPCBase

func _ready() -> void:
	npc_id = "cousin2"
	npc_name = "二表哥"
	sprite_color = Color(0.5, 0.7, 0.3, 1)
	default_text = "走啊走啊，待着多无聊！"
	default_expression = "grin"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		{
			"id": "c2_event_1",
			"conditions": [],
			"text": "走！带你去抓青蛙！",
			"expression": "grin",
			"choices": [
				{"text": "走！", "effects": {"好奇": 1, "体力": 1, "亲密": 1}},
				{"text": "去哪里抓？", "effects": {"好奇": 1}}
			]
		}
	]
