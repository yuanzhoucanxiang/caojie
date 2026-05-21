## 职责：小明NPC——定义小明的专属事件数据
extends NPCBase

func _ready() -> void:
	npc_id = "xiaoming"
	npc_name = "小明"
	sprite_color = Color(0.7, 0.55, 0.35, 1)
	default_text = "走不走？我带你去个好玩的地方！"
	default_expression = "grin"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		{
			"id": "xm_event_1",
			"conditions": [],
			"text": "哎！你是新来的吧？我叫亚明，大家都叫我小明！",
			"expression": "grin",
			"choices": [
				{"text": "我叫___，你好！", "effects": {"懂事": 1, "亲密": 1}},
				{"text": "（点点头）", "effects": {}}
			]
		}
	]
