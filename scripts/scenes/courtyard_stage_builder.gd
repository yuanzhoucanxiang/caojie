## 职责：外婆家院落舞台构图生成器，隐藏旧占位块并生成分层院落视觉
## 谁使用它：scripts/main.gd、院落相关回归测试
## 它使用谁：Godot ColorRect / Polygon2D / Line2D / Sprite2D 节点

extends RefCounted

const GROUP_NAME := "generated_courtyard_stage"

const LEGACY_VISUAL_NAMES := [
	"Sky", "FarHills", "TreeFar", "MidHills", "TreeNear",
	"PathBack", "PathMid", "GrassBack", "PathFront", "GrassMid", "GrassFront",
	"SunlightGradient", "BuildingShadow", "YardGround",
	"HouseBody", "HouseRoof", "Floor1Windows", "Floor2Windows", "Floor2Window2",
	"Floor3Windows", "Floor3Window2", "OldHouseWall", "OldHouseRoof",
	"TreeTrunk", "TreeCrown",
]


static func rebuild(parent: Node2D, spec: Dictionary) -> void:
	_hide_legacy_visuals(parent)
	_clear_generated(parent)
	for item in spec.get("items", []):
		var item_data: Dictionary = item
		_add_item(parent, item_data)


static func _clear_generated(parent: Node2D) -> void:
	for child in parent.get_children():
		if child.is_in_group(GROUP_NAME):
			child.queue_free()


static func _hide_legacy_visuals(root: Node) -> void:
	for child in root.get_children():
		_hide_legacy_visuals(child)
		if not child is CanvasItem:
			continue
		if child.is_in_group(GROUP_NAME):
			continue
		if LEGACY_VISUAL_NAMES.has(String(child.name)):
			var canvas_item := child as CanvasItem
			canvas_item.visible = false


static func _add_item(parent: Node2D, item: Dictionary) -> CanvasItem:
	match item.get("kind", "rect"):
		"line":
			return _add_line(parent, item)
		"ellipse":
			return _add_ellipse(parent, item)
		"poly":
			return _add_poly(parent, item["name"], item["points"], item["color"], int(item.get("z", 0)))
		"sprite":
			return _add_sprite(parent, item)
		_:
			return _add_rect(parent, item["name"], item["pos"], item["size"], item["color"], int(item.get("z", 0)))


static func _add_rect(parent: Node2D, node_name: String, pos: Vector2, size: Vector2, color: Color, z: int) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.position = pos
	rect.size = size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = z
	rect.z_as_relative = false
	rect.add_to_group(GROUP_NAME)
	parent.add_child(rect)
	return rect


static func _add_sprite(parent: Node2D, item: Dictionary) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = item["name"]
	sprite.texture = load(item["texture"])
	sprite.centered = false
	sprite.position = item["pos"]
	if sprite.texture:
		var target_size: Vector2 = item.get("size", sprite.texture.get_size())
		var texture_size := sprite.texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			sprite.scale = Vector2(target_size.x / texture_size.x, target_size.y / texture_size.y)
	sprite.z_index = int(item.get("z", 0))
	sprite.z_as_relative = false
	sprite.add_to_group(GROUP_NAME)
	parent.add_child(sprite)
	return sprite


static func _add_line(parent: Node2D, item: Dictionary) -> Line2D:
	var line := Line2D.new()
	line.name = item["name"]
	line.points = PackedVector2Array([item["from"], item["to"]])
	line.width = float(item.get("width", 2.0))
	line.default_color = item["color"]
	line.z_index = int(item.get("z", 0))
	line.z_as_relative = false
	line.add_to_group(GROUP_NAME)
	parent.add_child(line)
	return line


static func _add_ellipse(parent: Node2D, item: Dictionary) -> Polygon2D:
	var pos: Vector2 = item["pos"]
	var size: Vector2 = item["size"]
	var center := pos + size * 0.5
	var radius := size * 0.5
	var segments := int(item.get("segments", 24))
	var points: Array = []
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return _add_poly(parent, item["name"], points, item["color"], int(item.get("z", 0)))


static func _add_poly(parent: Node2D, node_name: String, points: Array, color: Color, z: int) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.name = node_name
	poly.polygon = PackedVector2Array(points)
	poly.color = color
	poly.z_index = z
	poly.z_as_relative = false
	poly.add_to_group(GROUP_NAME)
	parent.add_child(poly)
	return poly
