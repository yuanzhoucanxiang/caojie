## 职责：玩家角色——四方向移动、深度缩放、按E广播交互信号
## 谁使用它：Main（暂停/恢复控制）
## 它使用谁：NPCBase（通过 interact_pressed 广播信号，NPC 自行判断）

extends CharacterBody2D

signal interact_pressed

const ZOOM_MIN: float = 0.9
const ZOOM_MAX: float = 2.5
const ZOOM_STEP: float = 0.1
const ZOOM_DEFAULT: float = 1.25

const SPRITE_SIZE: Vector2 = Vector2(32, 54)
const SPRITE_COLOR: Color = Color(0.267, 0.533, 0.8, 1)
const DEPTH_MIN_Y: float = 360.0
const DEPTH_MAX_Y: float = 520.0
const SCALE_MIN: float = 0.85
const SCALE_MAX: float = 1.0
const LEFT_BOUND: float = 32.0
const RIGHT_BOUND: float = 1680.0

@export var speed: float = 270.0
@export var depth_speed: float = 200.0

var _step_timer: float = 0.0
var _target_zoom: float = ZOOM_DEFAULT

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	SaveManager.apply_position(self)
	_target_zoom = camera.zoom.x


func _draw() -> void:
	draw_rect(Rect2(-SPRITE_SIZE.x / 2, -SPRITE_SIZE.y, SPRITE_SIZE.x, SPRITE_SIZE.y), SPRITE_COLOR)


func _physics_process(_delta: float) -> void:
	var horizontal: float = Input.get_axis("move_left", "move_right")
	var vertical: float = Input.get_axis("move_up", "move_down")

	velocity.x = horizontal * speed
	velocity.y = vertical * depth_speed

	move_and_slide()

	if velocity.length() > 10.0:
		_step_timer += _delta
		if _step_timer > 0.35:
			_step_timer = 0.0
			AudioManager.play_sfx("SFX/footstep.ogg")
	else:
		_step_timer = 0.0

	position.x = clampf(position.x, LEFT_BOUND, RIGHT_BOUND)
	position.y = clampf(position.y, DEPTH_MIN_Y, DEPTH_MAX_Y)

	if Input.is_action_just_pressed("interact"):
		interact_pressed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _can_zoom():
		return
	if not event is InputEventMouseButton:
		return
	var mb := event as InputEventMouseButton
	if not mb.pressed:
		return
	match mb.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = maxf(_target_zoom - ZOOM_STEP, ZOOM_MIN)
			_apply_zoom()
		MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = minf(_target_zoom + ZOOM_STEP, ZOOM_MAX)
			_apply_zoom()


func _can_zoom() -> bool:
	var area := SceneManager.get_current_area()
	return area == "courtyard" or area == "village_road"


const CAMERA_BASE_OFFSET: float = -60.0

var _zoom_tween: Tween

func _apply_zoom() -> void:
	if _zoom_tween and _zoom_tween.is_valid():
		_zoom_tween.kill()
	var ratio := ZOOM_DEFAULT / _target_zoom
	var target_offset := Vector2(0, CAMERA_BASE_OFFSET * ratio)
	_zoom_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_zoom_tween.set_parallel(true)
	_zoom_tween.tween_property(camera, "zoom", Vector2(_target_zoom, _target_zoom), 0.25)
	_zoom_tween.tween_property(camera, "position", target_offset, 0.25)


func _process(_delta: float) -> void:
	_update_depth_scale()
	_update_depth_sort()


func _update_depth_scale() -> void:
	var t: float = clampf((position.y - DEPTH_MIN_Y) / (DEPTH_MAX_Y - DEPTH_MIN_Y), 0.0, 1.0)
	var s: float = lerp(SCALE_MIN, SCALE_MAX, t)
	scale = Vector2(s, s)


func _update_depth_sort() -> void:
	z_index = int(position.y)
