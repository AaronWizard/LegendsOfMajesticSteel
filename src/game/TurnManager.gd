class_name TurnManager
extends Node

signal battle_started(turn_order)

signal turn_started(actor, range_data)
signal action_starting(action)
signal turn_ended

signal actor_died(turn_index)

signal player_turn_waiting_for_input(player_turn, actors)
signal player_waiting_for_input(player, actor)

const _PRE_TURN_WAIT_TIME := 0.3
const _POST_TURN_WAIT_TIME := 0.2

var running := false

var _map: Map

var _turn_order := []
var _turn_index := 0

onready var _player_turn := $PlayerTurn as TurnController
onready var _ai_turn := $AITurn as TurnController

onready var _player := $Player as ActorController
onready var _ai := $AI as ActorController


func start(map: Map) -> void:
	_start(map)
	call_deferred("_take_turn")


func _start(map: Map) -> void:
	_map = map

	# warning-ignore:return_value_discarded
	_map.connect("actor_dying", self, "_on_actor_dying")

	_start_battle()

	running = true


func _take_turn():
	if running:
		_refresh_range_data()
		_get_next_actor()
	else:
		_end()


func _start_battle() -> void:
	_turn_order.clear()
	_turn_index = 0

	for a in _map.get_actors():
		var actor := a as Actor
		actor.start_battle()
		_turn_order.append(actor.faction)

	randomize()
	_turn_order.shuffle()

	emit_signal("battle_started", _turn_order)


func _refresh_range_data(actor_to_exclude: Actor = null) -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		if actor != actor_to_exclude:
			actor.range_data = RangeDataFactory.create_range_data(
					actor, _map)


func _start_round() -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		actor.start_round()


func _end() -> void:
	_map.disconnect("actor_dying", self, "_on_actor_dying")
	_map = null


func _get_next_actor() -> void:
	if _turn_index == 0:
		_start_round()

	var faction := _turn_order[_turn_index] as int

	var actors := _get_active_actors(faction)
	if actors.size() > 1:
		var controller := _get_actor_turn_controller(faction)
		controller.pick_actor(_get_active_actors(faction))
	else:
		var actor := actors[0] as Actor
		_on_actor_picked(actor)


func _get_active_actors(faction: int) -> Array:
	var result := []

	for a in _map.get_actors():
		var actor := a as Actor
		if (actor.faction == faction) and not actor.round_finished:
			result.append(actor)

	return result


func _on_actor_picked(actor: Actor) -> void:
	var controller := _get_actor_controller(actor)

	if controller:
		actor.start_turn()
		emit_signal("turn_started", actor)

		if controller.pauses:
			yield(get_tree().create_timer(_PRE_TURN_WAIT_TIME), "timeout")

		while actor.battle_stats.is_alive \
				and not actor.turn_finished:
			controller.call_deferred("determine_action", actor, _map)
			var action := yield(controller, "determined_action") as Action

			if action:
				emit_signal("action_starting", action)
				action.start()
				yield(action, "finished")
			else:
				# Action is a wait
				actor.take_turn()

			if actor.battle_stats.is_alive and not actor.turn_finished:
				_refresh_range_data(actor)

		yield(get_tree().create_timer(_POST_TURN_WAIT_TIME), "timeout")

		_turn_index = (_turn_index + 1) % _turn_order.size()
		emit_signal("turn_ended")

	call_deferred("_take_turn")


func _get_actor_turn_controller(faction: int) -> TurnController:
	var result: TurnController = null

	match faction:
		Actor.Faction.PLAYER:
			result = _player_turn
		Actor.Faction.ENEMY:
			result = _ai_turn
		_:
			assert(false)

	return result


func _get_actor_controller(actor: Actor) -> ActorController:
	var result: ActorController = null

	match actor.faction:
		Actor.Faction.PLAYER:
			result = _player
		Actor.Faction.ENEMY:
			result = _ai
		_:
			assert(false)

	return result


func _on_actor_dying(actor: Actor) -> void:
	var index: int
	if actor.round_finished:
		index = _turn_order.rfind(actor.faction, _turn_index)
	else:
		index = _turn_order.rfind(actor.faction)

	if index > -1:
		_turn_order.remove(index)
		emit_signal("actor_died", index)
		if index < _turn_index:
			_turn_index -= 1


func _on_PlayerTurn_waiting_for_input(player_turn: PlayerTurn, actors: Array) \
		-> void:
	emit_signal("player_turn_waiting_for_input", player_turn, actors)


func _on_Player_waiting_for_input(player: Player, actor: Actor) \
		-> void:
	emit_signal("player_waiting_for_input", player, actor)
