extends Node

signal attribute_changed(attr_name: String, new_value: int)
signal event_completed(event_id: String)

var attributes: Dictionary = {
	"懂事": 0,
	"好奇": 0,
	"勤劳": 0,
	"体力": 0,
	"亲密": 0,
}

var completed_events: Array[String] = []


func change_attribute(attr_name: String, delta: int) -> void:
	if attributes.has(attr_name):
		attributes[attr_name] += delta
		attribute_changed.emit(attr_name, attributes[attr_name])


func complete_event(event_id: String) -> void:
	if event_id not in completed_events:
		completed_events.append(event_id)
		event_completed.emit(event_id)


func is_event_completed(event_id: String) -> bool:
	return event_id in completed_events


func check_attribute(attr_name: String, min_value: int) -> bool:
	return attributes.get(attr_name, 0) >= min_value
