class_name BattleStats
extends Node

const MAX_STAMINA := 20

var stamina: int
var did_ability: bool

var is_alive: bool setget , get_is_alive
var finished: bool setget , get_finished


func start_turn() -> void:
	stamina = MAX_STAMINA
	did_ability = false


func get_is_alive() -> bool:
	return stamina > 0


func get_finished() -> bool:
	return did_ability
