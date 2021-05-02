class_name Game
extends Node

export var start_map_file: PackedScene = null

var map: Map setget , get_map
var current_actor: Actor setget , get_current_actor

var interface: BattleInterface setget , get_interface
var turn_manager: TurnManager setget , get_turn_manager

var _map: Map
var _current_actor: Actor

onready var _screen_transition := $CanvasLayer/ScreenTransition \
		as ScreenTransition

onready var _map_container := $Map
onready var _interface := $BattleInterface as BattleInterface
onready var _turn_manager := $TurnManager as TurnManager

onready var _state_machine := $StateMachine as StateMachine
onready var _next_turn_state := $StateMachine/NextTurnState as State


func _ready() -> void:
	_current_actor = null
	_load_map(start_map_file)
	_screen_transition.fade_in()


func get_map() -> Map:
	return _map


func get_current_actor() -> Actor:
	return _current_actor


func get_interface() -> BattleInterface:
	return _interface


func get_turn_manager() -> TurnManager:
	return _turn_manager


func refresh_range_data(exclude_current: bool) -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		if not exclude_current or actor != _current_actor:
			actor.range_data = RangeDataFactory.create_range_data(actor, _map)


func get_active_actors(faction: int) -> Array:
	var result := []

	for a in _map.get_actors_by_faction(faction):
		var actor := a as Actor
		if not actor.turn_status.round_finished:
			result.append(actor)

	return result


func start_turn(actor: Actor) -> void:
	assert(actor.stats.is_alive)
	_current_actor = actor
	_interface.set_current_actor(actor)


func end_turn() -> void:
	_current_actor.turn_status.end_turn()
	_current_actor = null
	_interface.clear_current_actor()
	_turn_manager.advance_turn()
	_interface.gui.turn_queue.next_turn()


func _load_map(map_file: PackedScene) -> void:
	if _map != null:
		_map.disconnect("actor_dying", self, "_on_map_actor_dying")
		_map_container.remove_child(_map)
		_map.queue_free()
		_map = null
		_interface.current_map = null
		assert(_map_container.get_child_count() == 0)

	var new_map := map_file.instance() as Map
	assert(new_map != null)

	_map_container.add_child(new_map)
	_map = new_map
	_interface.current_map = new_map

	# warning-ignore:return_value_discarded
	_map.connect("actor_dying", self, "_on_map_actor_dying")


func _start_battle() -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		actor.start_battle()

	_turn_manager.roll_initiative(_map.get_actors())
	_interface.gui.turn_queue.set_queue(_turn_manager.turn_order)

	_state_machine.change_state(_next_turn_state)


func _on_ScreenTransition_faded_in() -> void:
	_start_battle()


func _on_map_actor_dying(actor: Actor) -> void:
	var turn_index := _turn_manager.remove_actor(actor)
	_interface.gui.turn_queue.remove_icon(turn_index)


func _on_TurnManager_round_started() -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		actor.turn_status.start_round()
