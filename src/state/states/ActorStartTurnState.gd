class_name ActorStartTurnState
extends GameState

export var player_turn_state_path: NodePath
export var ai_turn_state_path: NodePath

onready var _player_turn_state := get_node(player_turn_state_path) as State
onready var _ai_turn_state := get_node(ai_turn_state_path) as State


func start(_data: Dictionary) -> void:
	call_deferred("_start_turn")


func _start_turn() -> void:
	assert(_game.current_actor.is_alive)
	assert(not _game.current_actor.turn_finished)

	match _game.current_actor.faction:
		Actor.Faction.PLAYER:
			_next_state(_player_turn_state)
		Actor.Faction.ENEMY:
			_next_state(_ai_turn_state)


func _next_state(state: State) -> void:
	emit_signal("state_change_requested", state)
