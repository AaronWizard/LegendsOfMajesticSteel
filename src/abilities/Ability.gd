class_name Ability
extends Node

signal finished


func get_actor() -> Actor:
	return owner as Actor


func get_current_range(map: Map) -> Array:
	return get_range(get_actor().cell, map)


# warning-ignore:unused_argument
func get_range(source_cell: Vector2, map: Map) -> Array:
	print("Ability must implement get_range()")
	return [source_cell]


func is_current_valid_target(target_cell: Vector2, map: Map) -> bool:
	return is_valid_target(target_cell, get_actor().cell, map)


# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func is_valid_target(target_cell: Vector2, source_cell: Vector2, map: Map) \
		-> bool:
	print("Ability must implement is_valid_target()")
	return false


func get_current_valid_targets(map: Map) -> Array:
	return get_valid_targets(get_actor().cell, map)


# warning-ignore:unused_argument
func get_valid_targets(source_cell: Vector2, map: Map) -> Array:
	print("Ability must implement get_valid_targets()")
	return [source_cell]


func get_current_aoe(target_cell: Vector2, map: Map) -> Array:
	return get_aoe(get_actor().cell, target_cell, map)


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func get_aoe(source_cell: Vector2, target_cell: Vector2, map: Map) -> Array:
	return [target_cell]


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func start(target: Vector2, map: Map) -> void:
	print("Ability must implement start()")
	emit_signal("finished")
