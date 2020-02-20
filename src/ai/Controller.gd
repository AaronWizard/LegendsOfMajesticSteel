class_name Controller
extends Node

signal determined_action(action)


func _ready() -> void:
	assert(get_actor())
	get_actor().controller = self


func get_actor() -> Actor:
	var result: Actor = null
	var parent = get_parent()
	if parent is Actor:
		result = parent
	return result


func get_map() -> Map:
	return get_actor().map


func get_battle_stats() -> BattleStats:
	return get_actor().battle_stats


# warning-ignore:unused_argument
func connect_to_gui(gui: BattleGUI) -> void:
	print("Controller: Must implement connect_to_gui()")


# warning-ignore:unused_argument
func disconnect_from_gui(gui: BattleGUI) -> void:
	print("Controller: Must implement disconnect_from_gui()")


func determine_action() -> void:
	print("Controller: Must implement determine_action()")
	emit_signal("determined_action", null)
