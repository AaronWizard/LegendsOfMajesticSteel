class_name ActorController
extends Node

signal determined_action(action)

var pauses := false setget , get_pauses


func _ready() -> void:
	assert(get_actor())
	get_actor().controller = self


func get_pauses() -> bool:
	return false


func get_actor() -> Actor:
	var result: Actor = null
	var parent = get_parent()
	if parent is Actor:
		result = parent
	return result


# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func determine_action(map: Map, range_data: RangeData, control: BattleControl) \
		-> void:
	print("ActorController: Must implement determine_action()")
	emit_signal("determined_action", null)
