## 职责：玩家角色——四方向移动、深度缩放、按E广播交互信号
## 谁使用它：Main（暂停/恢复控制）
## 它使用谁：NPCBase（通过 interact_pressed 广播信号，NPC 自行判断）

extends CharacterBody2D

signal interact_pressed

@export var speed: float = 200.0
@export var depth_speed: float = 150.0

const SPRITE_SIZE: Vector2 = Vector2(24, 42)
const SPRITE_COLOR: Color = Color(0.267, 0.533, 0.8, 1)

const DEPTH_MIN_Y: float = 235.0
const DEPTH_MAX_Y: float = 275.0
const SCALE_MIN: float = 0.85
const SCALE_MAX: float = 1.0

const LEFT_BOUND: float = 24.0
const RIGHT_BOUND: float = 1256.0


func _draw() -> void:
	draw_rect(Rect2(-SPRITE_SIZE.x / 2, -SPRITE_SIZE.y, SPRITE_SIZE.x, SPRITE_SIZE.y), SPRITE_COLOR)


func _physics_process(delta: float) -> void:
	var horizontal: float = Input.get_axis("move_left", "move_right")
	var vertical: float = Input.get_axis("move_up", "move_down")

	velocity.x = horizontal * speed
	velocity.y = vertical * depth_speed

	move_and_slide()

	position.x = clampf(position.x, LEFT_BOUND, RIGHT_BOUND)
	position.y = clampf(position.y, DEPTH_MIN_Y, DEPTH_MAX_Y)

	if Input.is_action_just_pressed("interact"):
		interact_pressed.emit()


func _process(_delta: float) -> void:
	_update_depth_scale()


func _update_depth_scale() -> void:
	var t: float = clampf((position.y - DEPTH_MIN_Y) / (DEPTH_MAX_Y - DEPTH_MIN_Y), 0.0, 1.0)
	var s: float = lerp(SCALE_MIN, SCALE_MAX, t)
	scale = Vector2(s, s)
