extends Node

export var start_map_file: PackedScene = null

onready var _map_container := $Map
onready var _turn_manager := $TurnManager as TurnManager
onready var _interface := $BattleInterface as BattleInterface

func _ready() -> void:
	if start_map_file:
		load_map(start_map_file)

	_interface.gui.buttons_visible = false
	_interface.mouse.dragging_enabled = false
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


func _on_TurnManager_turn_started(actor: Actor, range_data: RangeData) -> void:
	_interface.map_highlights.moves_visible = true
	_interface.map_highlights.set_moves(range_data.visible_move_range.keys())
	_interface.camera.follow_actor(actor)

	_interface.current_actor = actor


func _on_TurnManager_action_starting(action: Action) -> void:
	_interface.gui.buttons_visible = false
	_interface.mouse.dragging_enabled = false

	_interface.camera.follow_actor(action.actor)
	_interface.map_highlights.moves_visible = action.show_map_highlights()


func _on_TurnManager_turn_ended() -> void:
	_interface.map_highlights.moves_visible = false
	_interface.gui.turn_queue.next_turn()

	_interface.current_actor = null


func _on_TurnManager_actor_died(turn_index: int) -> void:
	_interface.gui.turn_queue.remove_icon(turn_index)


func _on_TurnManager_player_turn_waiting_for_input( \
		player_turn: PlayerTurn, actors: Array) -> void:
	_interface.start_player_turn(player_turn, actors)


func _on_TurnManager_player_waiting_for_input(
		player: Player, _actor: Actor, _map: Map) -> void:
	_interface.start_player(player)
