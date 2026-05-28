## 职责：室内舞台构图生成器——用文字化坐标表生成墙面、家具、光带和前景遮罩
## 谁使用它：house_floor1/2/3 场景控制器
## 它使用谁：Godot Polygon2D / ColorRect 节点

class_name InteriorStageBuilder
extends RefCounted

const GROUP_NAME := "generated_interior_stage"


static func rebuild(parent: Node2D, spec: Dictionary) -> void:
	_hide_legacy_stage_nodes(parent)
	_clear_generated(parent)
	_add_room_shell(parent, spec)
	_add_light_layers(parent, spec)
	for item in spec.get("items", []):
		var item_data: Dictionary = item
		_add_item(parent, item_data)
	for item in spec.get("foreground", []):
		var foreground_data: Dictionary = item
		_add_item(parent, foreground_data)


static func _clear_generated(parent: Node2D) -> void:
	for child in parent.get_children():
		if child.is_in_group(GROUP_NAME):
			child.queue_free()


static func _hide_legacy_stage_nodes(parent: Node2D) -> void:
	var prefixes := [
		"Struct", "TopShadow", "MidShadow", "LeftDoor", "RightDoor",
		"Window", "Bed", "Desk", "GrandparentsRoom", "UncleRoom", "Cousin2Room",
	]
	for child in parent.get_children():
		if not child is CanvasItem:
			continue
		var child_name := String(child.name)
		for prefix in prefixes:
			if child_name.begins_with(prefix):
				child.visible = false
				break


static func _add_room_shell(parent: Node2D, spec: Dictionary) -> void:
	var width: float = spec.get("width", 640.0)
	var height: float = spec.get("height", 480.0)
	var ceiling_h: float = spec.get("ceiling_h", 80.0)
	var floor_y: float = spec.get("floor_y", 340.0)
	var wall: float = spec.get("wall", 24.0)
	var side_bottom: float = spec.get("side_bottom", 6.0)
	var palette: Dictionary = spec.get("palette", {})

	_add_rect(parent, "StageCeiling", Vector2.ZERO, Vector2(width, ceiling_h), palette.get("ceiling", Color(0.28, 0.24, 0.2, 1)), -120)
	_add_rect(parent, "StageBackWall", Vector2(wall, ceiling_h), Vector2(width - wall * 2.0, floor_y - ceiling_h), palette.get("back_wall", Color(0.68, 0.62, 0.54, 1)), -110)
	_add_poly(parent, "StageLeftWall", [
		Vector2(0, ceiling_h), Vector2(wall, ceiling_h), Vector2(wall, floor_y),
		Vector2(side_bottom, height), Vector2(0, height),
	], palette.get("side_wall", Color(0.42, 0.36, 0.3, 1)), -105)
	_add_poly(parent, "StageRightWall", [
		Vector2(width - wall, ceiling_h), Vector2(width, ceiling_h), Vector2(width, height),
		Vector2(width - side_bottom, height), Vector2(width - wall, floor_y),
	], palette.get("side_wall", Color(0.42, 0.36, 0.3, 1)), -105)
	_add_poly(parent, "StageFloor", [
		Vector2(side_bottom, height), Vector2(width - side_bottom, height),
		Vector2(width - wall, floor_y), Vector2(wall, floor_y),
	], palette.get("floor", Color(0.46, 0.38, 0.28, 1)), -20)


static func _add_light_layers(parent: Node2D, spec: Dictionary) -> void:
	for layer in spec.get("lights", []):
		var layer_data: Dictionary = layer
		_add_rect(
			parent,
			layer_data.get("name", "LightLayer"),
			layer_data.get("pos", Vector2.ZERO),
			layer_data.get("size", Vector2(100, 100)),
			layer_data.get("color", Color(0.8, 0.7, 0.55, 0.2)),
			layer_data.get("z", 60)
		)


static func _add_item(parent: Node2D, item: Dictionary) -> void:
	match item.get("kind", "rect"):
		"line":
			_add_line(parent, item)
		"ellipse":
			_add_ellipse(parent, item)
		"poly":
			_add_poly(parent, item["name"], item["points"], item["color"], item.get("z", 0))
		_:
			_add_rect(parent, item["name"], item["pos"], item["size"], item["color"], item.get("z", 0))


static func _add_rect(parent: Node2D, node_name: String, pos: Vector2, size: Vector2, color: Color, z: int) -> Polygon2D:
	return _add_poly(parent, node_name, [
		pos,
		pos + Vector2(size.x, 0),
		pos + size,
		pos + Vector2(0, size.y),
	], color, z)


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
	var segments := int(item.get("segments", 18))
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
