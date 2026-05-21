## 职责：舅妈NPC——定义舅妈的专属事件数据
extends NPCBase

func _ready() -> void:
	npc_id = "aunt"
	npc_name = "舅妈"
	sprite_color = Color(0.8, 0.6, 0.3, 1)
	default_text = "在忙呢，等会儿吃饭。"
	default_expression = "normal"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		{
			"id": "at_event_1",
			"conditions": [],
			"text": "饿了吧？饭快好了，再等一会儿。",
			"expression": "kind",
			"choices": [
				{"text": "谢谢舅妈！", "effects": {"懂事": 1, "亲密": 1}},
				{"text": "还好，不饿。", "effects": {}}
			]
		}
	]
