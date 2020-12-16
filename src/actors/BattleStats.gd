class_name BattleStats
extends Node

signal round_started
signal turn_taken
signal stamina_changed(old_stamina, new_stamina)

var range_data: RangeData
var stamina: int

var turn_finished: bool setget , get_turn_finished
var round_finished: bool setget , get_round_finished

var is_alive: bool setget , get_is_alive

var _did_skill: bool = false
var _turns_left: int = false


func start_battle(max_stamina: int) -> void:
	stamina = max_stamina


func start_round() -> void:
	_turns_left = 1
	emit_signal("round_started")


func start_turn() -> void:
	_did_skill = false


func get_turn_finished() -> bool:
	return _did_skill


func get_round_finished() -> bool:
	return _turns_left == 0


func take_turn() -> void:
	_did_skill = true
	_turns_left -= 1
	emit_signal("turn_taken")


func get_is_alive() -> bool:
	return stamina > 0


func modify_stamina(mod: int) -> void:
	var old_stamina := stamina
	stamina += mod
	emit_signal("stamina_changed", old_stamina, stamina)
