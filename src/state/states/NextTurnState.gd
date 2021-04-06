class_name NextTurnState
extends GameState

export var player_pick_actor_state_path: NodePath
export var ai_pick_actor_state_path: NodePath

onready var _player_pick_actor := get_node(player_pick_actor_state_path) \
		as State
onready var _ai_pick_actor := get_node(ai_pick_actor_state_path) as State


func start(_data: Dictionary) -> void:
	call_deferred("_next_turn")


func _next_turn() -> void:
	_game.refresh_range_data()

	var faction := _game.turn_manager.next_faction()
	match faction:
		Actor.Faction.PLAYER:
			_pick_actor(_player_pick_actor)
		Actor.Faction.ENEMY:
			_pick_actor(_ai_pick_actor)
		_:
			push_error("Invalid faction '%d'" % faction)


func _pick_actor(state: State) -> void:
	emit_signal("state_change_requested", state)
