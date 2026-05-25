## 职责：音频管理——BGM 和 SFX 播放、音量控制
## 谁使用它：所有系统（场景切换、对话、UI、玩家）
## 它使用谁：Godot AudioServer

extends Node

const SFX_POOL_SIZE := 4
const SOUND_DIR := "res://assets/sounds/"
const SAMPLE_RATE := 22050.0

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
var _placeholders: Dictionary = {}


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
	if FileAccess.file_exists(full):
		return load(full) as AudioStream
	return _get_placeholder(path)


func _get_placeholder(path: String) -> AudioStream:
	var key := path.get_file()
	if _placeholders.has(key):
		return _placeholders[key]

	var gen: AudioStreamGenerator
	match key:
		"ui_click.ogg":
			gen = _tone_gen(600.0, 0.06, 0.25)
		"door_open.ogg":
			gen = _sweep_gen(250.0, 80.0, 0.22, 0.3)
		"footstep.ogg":
			gen = _noise_gen(0.04, 0.15)
		_:
			gen = _tone_gen(440.0, 0.08, 0.2)

	gen.mix_rate = SAMPLE_RATE
	gen.buffer_length = 0.3
	_placeholders[key] = gen
	return gen


func _tone_gen(freq: float, duration: float, volume: float) -> AudioStreamGenerator:
	var gen := AudioStreamGenerator.new()
	var playback := gen.get_stream_playback() as AudioStreamGeneratorPlayback
	var frames := int(SAMPLE_RATE * duration)
	for i in frames:
		var t := float(i) / SAMPLE_RATE
		var env := 1.0 - t / duration
		var s := sin(t * freq * TAU) * env * volume
		playback.push_frame(Vector2(s, s))
	return gen


func _sweep_gen(f0: float, f1: float, duration: float, volume: float) -> AudioStreamGenerator:
	var gen := AudioStreamGenerator.new()
	var playback := gen.get_stream_playback() as AudioStreamGeneratorPlayback
	var frames := int(SAMPLE_RATE * duration)
	for i in frames:
		var t := float(i) / SAMPLE_RATE
		var env := 1.0 - t / duration
		var f := lerpf(f0, f1, t / duration)
		var s := sin(t * f * TAU) * env * volume
		playback.push_frame(Vector2(s, s))
	return gen


func _noise_gen(duration: float, volume: float) -> AudioStreamGenerator:
	var gen := AudioStreamGenerator.new()
	var playback := gen.get_stream_playback() as AudioStreamGeneratorPlayback
	var frames := int(SAMPLE_RATE * duration)
	for i in frames:
		var t := float(i) / SAMPLE_RATE
		var env := 1.0 - t / duration
		var s := (randf() * 2.0 - 1.0) * env * volume
		playback.push_frame(Vector2(s, s))
	return gen
