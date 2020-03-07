class_name Ability
extends Node

signal finished


func get_actor() -> Actor:
	return owner as Actor


func get_map() -> Map:
	return get_actor().map


func get_battle_stats() -> BattleStats:
	return get_actor().battle_stats


func get_range(source_cell: Vector2) -> Array:
	print("Ability must implement get_range()")
	return []


func get_valid_targets(source_cell: Vector2) -> Array:
	print("Ability must get_valid_targets get_range()")
	return []


func get_aoe(source_cell: Vector2, target_cell: Vector2) -> Array:
	return [target_cell]


func start(target: Vector2) -> void:
	print("Ability must implement start()")
	emit_signal("finished")
