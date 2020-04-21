class_name TurnManager
extends Node

signal turn_started(actor, range_data)
signal action_started(actor)
signal action_ended(actor)
signal turn_ended(actor)

var running := false

var _map: Map
var _gui: BattleGUI

var _actors := []
var _next_index := 0


func start(map: Map, gui: BattleGUI) -> void:
	_start(map, gui)
	_run()


func _start(map: Map, gui: BattleGUI) -> void:
	_map = map
	_gui = gui

	# warning-ignore:return_value_discarded
	_map.connect("actor_removed", self, "_on_actor_removed")

	_gui.current_map = map

	for a in map.get_actors():
		var actor := a as Actor
		actor.battle_stats.start_battle()

	_actors = map.get_actors()
	_next_index = 0

	running = true


func _run() -> void:
	while running:
		var actor := _get_next_actor()
		var controller := actor.controller as Controller

		if controller:
			_gui.current_actor = actor

			actor.battle_stats.start_turn()
			var range_data := RangeData.new(actor, _map)

			emit_signal("turn_started", actor, range_data)

			if controller.pauses:
				yield(get_tree().create_timer(0.3), "timeout")

			while actor.battle_stats.is_alive \
					and not actor.battle_stats.finished:
				controller.call_deferred("determine_action",
						_map, range_data, _gui)
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
			_gui.current_actor = null

	_end()

func _end() -> void:
	_map.disconnect("actor_removed", self, "_on_actor_removed")
	_map = null
	_gui = null


func _get_next_actor() -> Actor:
	var result := _actors[_next_index] as Actor
	_next_index = (_next_index + 1) % _actors.size()
	return result


func _on_actor_removed(actor: Actor) -> void:
	var index := _actors.find(actor)
	assert(index > -1)

	_actors.remove(index)

	if _next_index == index:
		_next_index = _next_index % _actors.size()
