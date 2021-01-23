class_name BattleStats
extends Node

signal stamina_changed(old_stamina, new_stamina)

var stamina: int

var is_alive: bool setget , get_is_alive


func start_battle(max_stamina: int) -> void:
	stamina = max_stamina


func get_is_alive() -> bool:
	return stamina > 0


func modify_stamina(mod: int) -> void:
	var old_stamina := stamina
	stamina += mod
	emit_signal("stamina_changed", old_stamina, stamina)
