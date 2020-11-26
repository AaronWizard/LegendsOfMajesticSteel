class_name TurnManager
extends Node

signal battle_started(turn_order)
signal turn_started(actor, range_data)
signal action_chosen
signal action_starting(actor, show_map_highlights)
signal turn_ended

signal actor_died(turn_index)

const _PRE_TURN_WAIT_TIME := 0.3
const _POST_TURN_WAIT_TIME := 0.2

var running := false

var _map: Map
var _interface: BattleInterface

var _turn_order := []
var _turn_index := 0

onready var _player_turn := $PlayerTurn as TurnController
onready var _ai_turn := $AITurn as TurnController

onready var _player := $Player as ActorController
onready var _ai := $AI as ActorController


func start(map: Map, interface: BattleInterface) -> void:
	_start(map, interface)
	call_deferred("_take_turn")


func _start(map: Map, interface: BattleInterface) -> void:
	_map = map
	_interface = interface

	# warning-ignore:return_value_discarded
	_map.connect("actor_dying", self, "_on_actor_dying")

	_start_battle()

	running = true


func _take_turn():
	if running:
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


func _start_round() -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		actor.battle_stats.start_round()


func _end() -> void:
	_map.disconnect("actor_dying", self, "_on_actor_dying")
	_map = null
	_interface = null


func _get_next_actor() -> void:
	if _turn_index == 0:
		_start_round()

	var faction := _turn_order[_turn_index] as int

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
		controller.pick_actor(_get_active_actors(faction), _interface)
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
	var controller := _get_actor_controller(actor)

	if controller:
		actor.battle_stats.start_turn()
		var range_data := RangeData.new(actor, _map)

		emit_signal("turn_started", actor, range_data)

		if controller.pauses:
			yield(get_tree().create_timer(_PRE_TURN_WAIT_TIME), "timeout")

		while actor.battle_stats.is_alive \
				and not actor.battle_stats.turn_finished:
			controller.call_deferred("determine_action",
					actor, _map, range_data, _interface)
			var action := yield(controller, "determined_action") as Action
			emit_signal("action_chosen")

			if action:
				emit_signal("action_starting", actor,
						action.show_map_highlights())
				action.start()
				yield(action, "finished")
			else:
				# Action is a wait
				actor.battle_stats.take_turn()

		yield(get_tree().create_timer(_POST_TURN_WAIT_TIME), "timeout")

		_turn_index = (_turn_index + 1) % _turn_order.size()
		emit_signal("turn_ended")

	call_deferred("_take_turn")


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
	if actor.battle_stats.round_finished:
		index = _turn_order.rfind(actor.faction, _turn_index)
	else:
		index = _turn_order.rfind(actor.faction)

	if index > -1:
		_turn_order.remove(index)
		emit_signal("actor_died", index)
		if index < _turn_index:
			_turn_index -= 1
