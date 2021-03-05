class_name Game
extends Node

export var start_map_file: PackedScene = null

onready var _map_container := $Map
onready var _turn_manager := $TurnManager as TurnManager
onready var _interface := $BattleInterface as BattleInterface

onready var _state_machine := $StateMachine as StateMachine

onready var _wait_state := $StateMachine/WaitState as State
onready var _player_pick_actor_state := $StateMachine/PlayerPickActorState \
		as State
onready var _player_actor_move_state := $StateMachine/PlayerActorMoveState \
		as State


func _ready() -> void:
	if start_map_file:
		load_map(start_map_file)

	_turn_manager.start(get_current_map())


func get_current_map() -> Map:
	var result: Map = null
	if _map_container.get_child_count() > 0:
		assert(_map_container.get_child_count() == 1)
		result = _map_container.get_child(0) as Map

	return result


func load_map(map_file: PackedScene) -> void:
	var new_map := map_file.instance() as Map
	assert(new_map != null)
	_map_container.add_child(new_map)

	_interface.current_map = new_map


func _on_TurnManager_battle_started(turn_order: Array) -> void:
	_interface.gui.turn_queue.set_queue(turn_order)


func _on_TurnManager_turn_started(actor: Actor) -> void:
	_interface.set_current_actor(actor)


func _on_TurnManager_action_starting(action: Action) -> void:
	_state_machine.change_state(_wait_state)
	_interface.action_starting(action)


func _on_TurnManager_turn_ended() -> void:
	_interface.gui.turn_queue.next_turn()
	_interface.clear_current_actor()


func _on_TurnManager_actor_died(turn_index: int) -> void:
	_interface.gui.turn_queue.remove_icon(turn_index)


func _on_TurnManager_player_turn_waiting_for_input( \
		player_turn: PlayerTurn, actors: Array) -> void:
	_state_machine.change_state(_player_pick_actor_state, {
		player_turn = player_turn,
		actors = actors
	})


func _on_TurnManager_player_waiting_for_input(player: Player, actor: Actor) \
		-> void:
	_state_machine.change_state(_player_actor_move_state, {
		player = player,
		actor = actor
	})
