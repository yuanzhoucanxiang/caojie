## 职责：舅舅NPC——定义舅舅的专属事件数据
extends NPCBase

func _ready() -> void:
	npc_id = "uncle"
	npc_name = "舅舅"
	sprite_color = Color(0.6, 0.5, 0.4, 1)
	default_text = "（舅舅看了你一眼，没说话，继续抽烟。）"
	default_expression = "tired"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		{
			"id": "uc_event_1",
			"conditions": [],
			"text": "来了啊。",
			"expression": "tired",
			"choices": [
				{"text": "舅舅好！", "effects": {"懂事": 1}},
				{"text": "（点点头）", "effects": {}}
			]
		}
	]
