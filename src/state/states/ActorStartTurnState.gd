class_name ActorStartTurnState
extends GameState

export var player_turn_state_path: NodePath
export var ai_turn_state_path: NodePath
export var next_turn_state_path: NodePath

onready var _player_turn_state := get_node(player_turn_state_path) as State
onready var _ai_turn_state := get_node(ai_turn_state_path) as State
onready var _next_turn_state := get_node(next_turn_state_path) as State


func start(_data: Dictionary) -> void:
	call_deferred("_start_turn")


func _start_turn() -> void:
	if _game.current_actor.is_alive and not _game.current_actor.turn_finished:
		match _game.current_actor.faction:
			Actor.Faction.PLAYER:
				_next_state(_player_turn_state)
			Actor.Faction.ENEMY:
				_next_state(_ai_turn_state)
	else:
		_game.end_turn()
		_next_state(_next_turn_state)


func _next_state(state: State) -> void:
	emit_signal("state_change_requested", state)
