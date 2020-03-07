class_name Ability
extends Node

signal finished


func get_actor() -> Actor:
	return owner as Actor


func get_map() -> Map:
	return get_actor().map


func get_battle_stats() -> BattleStats:
	return get_actor().battle_stats


func get_current_range() -> Array:
	return get_range(get_actor().cell)


func get_range(source_cell: Vector2) -> Array:
	print("Ability must implement get_range()")
	return [source_cell]


func get_current_valid_targets() -> Array:
	return get_valid_targets(get_actor().cell)


func get_valid_targets(source_cell: Vector2) -> Array:
	print("Ability must get_valid_targets get_range()")
	return [source_cell]


func get_current_aoe(target_cell: Vector2) -> Array:
	return get_aoe(get_actor().cell, target_cell)


func get_aoe(source_cell: Vector2, target_cell: Vector2) -> Array:
	return [target_cell]


func start(target: Vector2) -> void:
	print("Ability must implement start()")
	emit_signal("finished")
