class_name Controller
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


func get_battle_stats() -> BattleStats:
	return get_actor().battle_stats


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func determine_action(map: Map, gui: BattleGUI) -> void:
	print("Controller: Must implement determine_action()")
	emit_signal("determined_action", null)
