class_name ActorActionState
extends GameState

export var turn_start_state_path: NodePath
export var next_turn_state_path: NodePath

onready var _turn_start_state := get_node(turn_start_state_path) as State
onready var _next_turn_state := get_node(next_turn_state_path) as State


func start(_data: Dictionary) -> void:
	call_deferred("_run_main")


func _ends_turn() -> bool:
	return true


func _run_main() -> void:
	# warning-ignore:void_assignment
	var s = _run()
	if s is GDScriptFunctionState:
		yield(s, "completed")
	_finish()


func _run() -> void:
	pass


func _finish() -> void:
	if not _game.current_actor.is_alive or _ends_turn():
		_game.end_turn()
		emit_signal("state_change_requested", _next_turn_state)
	else:
		emit_signal("state_change_requested", _turn_start_state)
