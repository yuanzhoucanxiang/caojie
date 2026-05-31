## 职责：二表哥NPC——定义二表哥的专属事件数据（童年首周事件链）
extends NPCBase

func _ready() -> void:
	npc_id = "cousin2"
	npc_name = "二表哥"
	sprite_color = Color(0.5, 0.7, 0.3, 1)
	npc_body_size = Vector2(38, 74)
	prompt_offset_y = 86.0
	default_text = "走啊走啊，待着多无聊！"
	default_expression = "grin"
	super._ready()


func _get_events() -> Array[Dictionary]:
	return [
		# —— 首周主线 ——
		{
			"id": "w1_c2_invite_play",
			"conditions": ["event_completed:w1_gm_arrival"],
			"text": "嘿！你就是外婆说的那个弟弟吧？走，我带你逛逛院子！",
			"expression": "grin",
			"choices": [
				{"text": "走！", "effects": {"好奇": 1, "体力": 1, "亲密": 1}},
				{"text": "外婆让我别跑远……", "effects": {"懂事": 1}}
			]
		},
		{
			"id": "w1_c2_stone_table_task",
			"conditions": ["event_completed:w1_c2_invite_play"],
			"text": "看到那边石桌没有？我们去那儿拍纸片玩，我教你规则！",
			"expression": "grin",
			"choices": [
				{"text": "我去石桌等你！", "effects": {"亲密": 1}},
				{"text": "你先教我规则。", "effects": {"好奇": 1}}
			]
		},
		{
			"id": "w1_c2_old_house_dare",
			"conditions": ["event_completed:w1_act_stone_table_game"],
			"text": "你看到那边老屋没有？听说以前有人住的，现在没人敢进去。你敢不敢去看看门口？",
			"expression": "grin",
			"choices": [
				{"text": "就看一眼。", "effects": {"好奇": 1}},
				{"text": "先问外婆吧。", "effects": {"懂事": 1}}
			]
		},
		# —— 日常（repeatable 放最后）——
		{
			"id": "w1_c2_daily_repeat",
			"conditions": ["event_completed:w1_c2_old_house_dare"],
			"text": "走不走？今天去哪玩？",
			"expression": "grin",
			"choices": [
				{"text": "等一下！", "effects": {}},
				{"text": "你自己去吧。", "effects": {}}
			],
			"repeatable": true
		},
	]
