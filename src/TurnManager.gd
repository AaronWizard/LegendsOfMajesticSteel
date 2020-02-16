class_name TurnManager
extends Node

signal followed_actor(actor)
signal set_movement_range(move_range)
signal cleared_map_highlights

var running := false

var _current_index := 0


func start(map: Map) -> void:
	var actors := map.get_actors()

	running = true
	_current_index = 0

	while running:
		var actor := actors[_current_index] as Actor
		var controller := actor.controller as Controller
		if controller:
			_do_pathfinding(controller)

			emit_signal("followed_actor", actor)

			controller.determine_action()
			var action: Action = yield(controller, "determined_action")
			emit_signal("cleared_map_highlights")
			if action:
				action.start()
				yield(action, "finished")

		_current_index = (_current_index + 1) % actors.size()


func _do_pathfinding(controller: Controller) -> void:
	controller.calculate_ranges()
	emit_signal("set_movement_range", controller.walk_cells)
