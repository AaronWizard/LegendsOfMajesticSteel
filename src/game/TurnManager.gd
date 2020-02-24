class_name TurnManager
extends Node

signal turn_started(actor)
signal action_started(actor)
signal action_ended(actor)
signal turn_ended(actor)

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

			emit_signal("turn_started", actor)

			while not battle_stats.finished:
				controller.call_deferred("determine_action", gui)
				var action: Action = yield(controller, "determined_action")
				if controller.pauses:
					yield(get_tree().create_timer(0.25), "timeout")
				if action:
					action.start()
					emit_signal("action_started", actor)
					yield(action, "finished")
					emit_signal("action_ended", actor)

			if controller.pauses:
				yield(get_tree().create_timer(0.25), "timeout")

			emit_signal("turn_ended", actor)

		_current_index = (_current_index + 1) % actors.size()
