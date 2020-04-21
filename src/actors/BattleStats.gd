class_name BattleStats
extends Node

signal stamina_changed(old_stamina, new_stamina)
signal died

const MAX_STAMINA := 20

var stamina: int
var did_ability: bool

var is_alive: bool setget , get_is_alive
var finished: bool setget , get_finished

func start_battle() -> void:
	stamina = MAX_STAMINA


func start_turn() -> void:
	did_ability = false


func get_is_alive() -> bool:
	return stamina > 0


func get_finished() -> bool:
	return did_ability


func modify_stamina(mod: int) -> void:
	var old_stamina := stamina
	stamina += mod
	emit_signal("stamina_changed", old_stamina, stamina)
	if not get_is_alive():
		emit_signal("died")
