class_name TurnManager
extends Node

var running := false

var _map: Map
var _interface: BattleInterface

var _turn_order := []
var _turn_index := 0

onready var _player_turn := $PlayerTurn as TurnController
onready var _ai_turn := $AITurn as TurnController

onready var _player := $Player as ActorController


func start(map: Map, interface: BattleInterface) -> void:
	_start(map, interface)
	call_deferred("_take_turn")


func _start(map: Map, interface: BattleInterface) -> void:
	_map = map
	_interface = interface

	# warning-ignore:return_value_discarded
	_map.connect("actor_dying", self, "_on_actor_dying")

	_interface.current_map = map

	_start_battle()
	_interface_cleanup()

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
		actor.battle_stats.start_battle()
		_turn_order.append(actor.faction)

	randomize()
	_turn_order.shuffle()
	_interface.gui.turn_queue.set_queue(_turn_order)


func _start_round() -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		actor.battle_stats.start_round()


func _turn_started(actor: Actor, range_data: RangeData) -> void:
	_interface.map_highlights.moves_visible = true
	_interface.map_highlights.set_moves(range_data.move_range)
	_interface.camera.follow_actor(actor)


func _turn_ended() -> void:
	_interface.map_highlights.moves_visible = false

	_interface.gui.turn_queue.next_turn()
	_turn_index = (_turn_index + 1) % _turn_order.size()


func _interface_cleanup() -> void:
	# Make sure these are true after a controller is run
	_interface.gui.buttons_visible = false
	_interface.mouse.dragging_enabled = false


func _action_started(actor: Actor, show_map_highlights: bool) -> void:
	_interface.camera.follow_actor(actor)
	_interface.map_highlights.moves_visible = show_map_highlights


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
		_interface.current_actor = actor

		actor.battle_stats.start_turn()
		var range_data := RangeData.new(actor, _map)

		_turn_started(actor, range_data)

		if controller.pauses:
			yield(get_tree().create_timer(0.3), "timeout")

		while actor.battle_stats.is_alive \
				and not actor.battle_stats.turn_finished:
			controller.call_deferred("determine_action",
					actor, _map, range_data, _interface)
			var action := yield(controller, "determined_action") as Action
			_interface_cleanup()

			if action:
				_action_started(actor, action.show_map_highlights())
				action.start()
				yield(action, "finished")
			else:
				# Action is a wait
				actor.battle_stats.take_turn()

		yield(get_tree().create_timer(0.2), "timeout")

		_turn_ended()

		_interface.current_actor = null

	call_deferred("_take_turn")


func _get_actor_controller(actor: Actor) -> ActorController:
	var result: ActorController = null

	match actor.faction:
		Actor.Faction.PLAYER:
			result = _player
		Actor.Faction.ENEMY:
			result = actor.controller as ActorController
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
		_interface.gui.turn_queue.remove_icon(index)
		if index < _turn_index:
			_turn_index -= 1
