class_name Controller
extends Node

signal determined_action(action)

var walk_cells := []


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


func calculate_ranges() -> void:
	walk_cells = BreadthFirstSearch.find_move_range(get_actor(), get_map())


func determine_action() -> void:
	print("Controller: Must implement determine_action()")
	emit_signal("determined_action", null)
