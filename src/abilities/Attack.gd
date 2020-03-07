class_name Attack
extends Ability

export var min_dist: int = 1
export var max_dist: int = 1


func get_range(source_cell: Vector2) -> Array:
	return TileGeometry.cells_in_range(source_cell, min_dist, max_dist)


func get_valid_targets(source_cell: Vector2) -> Array:
	var targets := []

	var ability_range := get_range(source_cell)
	for c in ability_range:
		var cell: Vector2 = c
		var other_actor := get_map().get_actor_on_cell(cell)
		if other_actor and (other_actor.faction != get_actor().faction):
			targets.append(cell)

	return targets


func start(target: Vector2) -> void:
	emit_signal("finished")
