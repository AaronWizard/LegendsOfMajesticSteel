class_name ActorAction
extends GameState

export var turn_start_state_path: NodePath

onready var _turn_start_state := get_node(turn_start_state_path) as State


func _finish(take_turn: bool) -> void:
	if take_turn:
		_game.current_actor.take_turn()
	emit_signal("state_change_requested", _turn_start_state)
