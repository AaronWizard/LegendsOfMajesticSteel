class_name TurnManager
extends Node

var running := false

var _map: Map
var _control: BattleControl

var _faction_order := []

onready var _player_turn := $PlayerTurn as PlayerTurn
onready var _ai_turn := $AITurn as AITurn


func start(map: Map, control: BattleControl) -> void:
	_start(map, control)
	call_deferred("_take_turn")


func _start(map: Map, control: BattleControl) -> void:
	_map = map
	_control = control

	# warning-ignore:return_value_discarded
	_map.connect("actor_removed", self, "_on_actor_removed")

	_control.current_map = map

	_start_battle()
	_controller_cleanup()

	running = true


func _take_turn():
	if running:
		_get_next_actor()
	else:
		_end()


func _start_battle() -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		actor.battle_stats.start_battle()


func _start_round() -> void:
	_faction_order.clear()

	for a in _map.get_actors():
		var actor := a as Actor
		actor.battle_stats.start_round()
		_faction_order.append(actor.faction)

	randomize()
	_faction_order.shuffle()

	_control.gui.turn_queue.set_queue(_faction_order)


func _turn_started(actor: Actor, range_data: RangeData) -> void:
	_control.map_highlights.moves_visible = true
	_control.map_highlights.set_moves(range_data.move_range)
	_control.camera.follow_actor(actor)


func _turn_ended() -> void:
	_control.map_highlights.moves_visible = false


func _controller_cleanup() -> void:
	# Make sure these are true after a controller is run
	_control.gui.buttons_visible = false
	_control.mouse.dragging_enabled = false


func _action_started(actor: Actor, show_map_highlights: bool) -> void:
	_control.camera.follow_actor(actor)
	_control.map_highlights.moves_visible = show_map_highlights


func _end() -> void:
	_map.disconnect("actor_removed", self, "_on_actor_removed")
	_map = null
	_control = null


func _get_next_actor() -> void:
	if _faction_order.empty():
		_start_round()
	else:
		_control.gui.turn_queue.next_turn()

	var faction := _faction_order.pop_front() as int

	var actors := _get_active_actors(faction)
	if actors.size() > 1:
		var controller: TurnController = null
		match faction:
			Actor.Faction.PLAYER:
				controller = _player_turn
			Actor.Faction.ENEMY:
				controller = _ai_turn
			_:
				assert(false)
		controller.pick_actor(_get_active_actors(faction), _control)
	else:
		var actor := actors[0] as Actor
		_on_actor_picked(actor)


func _get_active_actors(faction: int) -> Array:
	var result := []

	for a in _map.get_actors():
		var actor := a as Actor
		if (actor.faction == faction) and not actor.battle_stats.round_finished:
			result.append(actor)

	return result


func _on_actor_picked(actor: Actor) -> void:
	var controller := actor.controller as ActorController

	if controller:
		_control.current_actor = actor

		actor.battle_stats.start_turn()
		var range_data := RangeData.new(actor, _map)

		_turn_started(actor, range_data)

		if controller.pauses:
			yield(get_tree().create_timer(0.3), "timeout")

		while actor.battle_stats.is_alive \
				and not actor.battle_stats.turn_finished:
			controller.call_deferred("determine_action",
					_map, range_data, _control)
			var action := yield(controller, "determined_action") as Action
			_controller_cleanup()

			if action:
				_action_started(actor, action.show_map_highlights())
				action.start()
				yield(action, "finished")
			else:
				# Action is a wait
				actor.battle_stats.take_turn()

		yield(get_tree().create_timer(0.2), "timeout")

		_turn_ended()

		_control.current_actor = null

	call_deferred("_take_turn")


func _on_actor_removed(actor: Actor) -> void:
	if not actor.battle_stats.round_finished:
		var index := _faction_order.rfind(actor.faction)
		if index > -1:
			_faction_order.remove(index)
			_control.gui.turn_queue.remove_icon(index)
