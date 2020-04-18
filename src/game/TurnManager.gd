class_name TurnManager
extends Node

signal turn_started(actor, range_data)
signal action_started(actor)
signal action_ended(actor)
signal turn_ended(actor)

var running := false

var _current_index := 0


func start(map: Map, gui: BattleGUI) -> void:
	gui.current_map = map

	var actors := map.get_actors()

	running = true
	_current_index = 0

	while running:
		var actor := actors[_current_index] as Actor
		var controller := actor.controller as Controller

		if controller:
			gui.current_actor = actor

			actor.battle_stats.start_turn()
			var range_data := RangeData.new(actor, map)

			emit_signal("turn_started", actor, range_data)

			if controller.pauses:
				yield(get_tree().create_timer(0.3), "timeout")

			while not actor.battle_stats.finished:
				controller.call_deferred("determine_action",
						map, range_data, gui)
				var action: Action = yield(controller, "determined_action")

				if action:
					action.start()
					emit_signal("action_started", actor)
					yield(action, "finished")
					emit_signal("action_ended", actor)
				else:
					break

			yield(get_tree().create_timer(0.2), "timeout")

			emit_signal("turn_ended", actor)
			gui.current_actor = null

		_current_index = (_current_index + 1) % actors.size()
