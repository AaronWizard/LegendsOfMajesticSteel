class_name Ability
extends Node


class TargettingData:
	var target_range := []
	var valid_targets := []

	func _init(new_target_range: Array, new_valid_targets: Array) -> void:
		target_range = new_target_range
		valid_targets = new_valid_targets


signal finished


func get_targetting_data(source_actor: Actor, map: Map) -> TargettingData:
	var target_range := _get_range(source_actor, map)

	var valid_targets := []
	for c in target_range:
		var cell := c as Vector2
		if _is_valid_target(source_actor, map, cell):
			valid_targets.append(cell)

	return TargettingData.new(target_range, valid_targets)


# Override in subclasses
# Assumes target_cell is a valid target
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func get_aoe(source_actor: Actor, map: Map, target_cell: Vector2) -> Array:
	return [target_cell]


# Override in subclasses
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func start(source_actor: Actor, map: Map, target: Vector2) -> void:
	print("Ability must implement start()")
	emit_signal("finished")


# Override in subclasses
# warning-ignore:unused_argument
func _get_range(source_actor: Actor, map: Map) -> Array:
	return [source_actor.cell]


# Override in subclasses
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _is_valid_target(source_actor: Actor, map: Map, target_cell: Vector2) \
		-> bool:
	return true
