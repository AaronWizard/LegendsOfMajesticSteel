class_name TurnManager
extends Node

signal followed_actor(actor)
signal set_movement_range(move_range)
signal action_start
signal cleared_map_highlights

var running := false

var _current_index := 0


func start(map: Map, gui: BattleGUI) -> void:
	var actors := map.get_actors()

	running = true
	_current_index = 0

	while running:
		var actor := actors[_current_index] as Actor
		var controller := actor.controller as Controller
		var battle_stats := actor.battle_stats as BattleStats

		if controller:
			battle_stats.start_turn()
			controller.connect_to_gui(gui)

			emit_signal("followed_actor", actor)
			emit_signal("set_movement_range", battle_stats.walk_cells)

			while not battle_stats.finished:
				controller.determine_action()
				var action: Action = yield(controller, "determined_action")
				if action:
					action.start()
					emit_signal("action_start")
					yield(action, "finished")

			emit_signal("cleared_map_highlights")
			controller.disconnect_from_gui(gui)

		_current_index = (_current_index + 1) % actors.size()
