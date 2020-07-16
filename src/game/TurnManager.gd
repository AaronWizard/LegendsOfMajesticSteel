class_name TurnManager
extends Node

var running := false

var _map: Map
var _control: BattleControl

var _actors := []
var _next_index := 0


func start(map: Map, control: BattleControl) -> void:
	_start(map, control)
	_run()


func _start(map: Map, control: BattleControl) -> void:
	_map = map
	_control = control

	# warning-ignore:return_value_discarded
	_map.connect("actor_removed", self, "_on_actor_removed")

	_control.current_map = map

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
			_control.current_actor = actor

			actor.battle_stats.start_turn()
			var range_data := RangeData.new(actor, _map)

			_turn_started(actor, range_data)

			if controller.pauses:
				yield(get_tree().create_timer(0.3), "timeout")

			while actor.battle_stats.is_alive \
					and not actor.battle_stats.finished:
				controller.call_deferred("determine_action",
						_map, range_data, _control)
				var action: Action = yield(controller, "determined_action")

				if action:
					_action_started(actor, action.show_map_highlights())
					action.start()
					yield(action, "finished")
				else:
					break

			yield(get_tree().create_timer(0.2), "timeout")

			_control.current_actor = null

	_end()


func _turn_started(actor: Actor, range_data: RangeData) -> void:
	_control.map_highlights.moves_visible = true
	_control.map_highlights.set_moves(range_data.move_range)
	_control.camera.follow_actor(actor)


func _action_started(actor: Actor, show_map_highlights: bool) -> void:
	_control.camera.follow_actor(actor)
	_control.map_highlights.moves_visible = show_map_highlights


func _end() -> void:
	_map.disconnect("actor_removed", self, "_on_actor_removed")
	_map = null
	_control = null


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
