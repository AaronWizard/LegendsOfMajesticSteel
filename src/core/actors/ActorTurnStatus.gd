class_name ActorTurnStatus
extends Node

signal round_started(first_round)
signal round_finished

var round_finished: bool setget , get_round_finished

var _turns_left: int = 0

var _first_round := false


func start_battle() -> void:
	_first_round = true
	start_round()


func get_round_finished() -> bool:
	return _turns_left == 0


func start_round() -> void:
	_turns_left = 1
	emit_signal("round_started", _first_round)
	if _first_round:
		_first_round = false


func end_turn() -> void:
	_turns_left -= 1
	if get_round_finished():
		emit_signal("round_finished")
