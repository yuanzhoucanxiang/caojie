## 职责：音频管理——BGM 和 SFX 播放、音量控制
## 谁使用它：所有系统（场景切换、对话、UI、玩家）
## 它使用谁：Godot AudioServer

extends Node

const SFX_POOL_SIZE := 4
const SOUND_DIR := "res://assets/sounds/"

@export_range(-40, 0) var bgm_volume_db: float = -10.0:
	set(v):
		bgm_volume_db = v
		if _bgm_player:
			_bgm_player.volume_db = v

@export_range(-40, 0) var sfx_volume_db: float = -6.0:
	set(v):
		sfx_volume_db = v
		for p in _sfx_pool:
			p.volume_db = v

var _bgm_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0


func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = &"Master"
	_bgm_player.volume_db = bgm_volume_db
	add_child(_bgm_player)

	for _i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = &"Master"
		p.volume_db = sfx_volume_db
		add_child(p)
		_sfx_pool.append(p)


func play_bgm(path: String) -> void:
	var stream := _load_sound(path)
	if not stream:
		return
	if _bgm_player.playing and _bgm_player.stream == stream:
		return
	_bgm_player.stream = stream
	_bgm_player.play()


func stop_bgm() -> void:
	_bgm_player.stop()


func play_sfx(path: String) -> void:
	var stream := _load_sound(path)
	if not stream:
		return
	var p := _sfx_pool[_sfx_index]
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE
	p.stream = stream
	p.play()


func _load_sound(path: String) -> AudioStream:
	var full := SOUND_DIR + path
	if not FileAccess.file_exists(full):
		return null
	return load(full) as AudioStream
