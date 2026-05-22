## 职责：为场景中的 ColorRect 批量应用 procedurally 纹理 shader
## 谁使用它：各场景控制器的 _ready()
## 它使用谁：shaders/procedural_texture.gdshader

class_name TextureSetup
extends RefCounted

enum Pattern {
	NOISE = 0,
	BRICK = 1,
	WOOD_H = 2,
	WOOD_V = 3,
	DIRT = 4,
	GRASS = 5,
}

const SHADER_PATH := "res://shaders/procedural_texture.gdshader"


static func apply(
	node: Node,
	pattern: Pattern,
	texture_scale: float = 64.0,
	noise_intensity: float = 0.08,
) -> void:
	if not node is ColorRect:
		return
	var cr := node as ColorRect
	var shader := load(SHADER_PATH) as Shader
	if shader == null:
		return
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("base_color", cr.color)
	mat.set_shader_parameter("pattern", pattern)
	mat.set_shader_parameter("texture_scale", texture_scale)
	mat.set_shader_parameter("noise_intensity", noise_intensity)
	cr.material = mat


## 递归遍历所有子节点，对 ColorRect 按名称匹配应用纹理
static func apply_by_name(
	root: Node, rules: Dictionary,
	default_scale: float = 64.0, default_intensity: float = 0.08,
) -> void:
	_apply_recursive(root, rules, default_scale, default_intensity)


static func _apply_recursive(node: Node, rules: Dictionary, scale: float, intensity: float) -> void:
	if node is ColorRect:
		for name_pattern in rules:
			if name_pattern.to_lower() in node.name.to_lower():
				var rule = rules[name_pattern]
				var pat: Pattern = rule[0]
				var s: float = rule[1] if rule.size() > 1 else scale
				var i: float = rule[2] if rule.size() > 2 else intensity
				apply(node, pat, s, i)
				break
	for child in node.get_children():
		_apply_recursive(child, rules, scale, intensity)
