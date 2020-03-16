class_name Attack
extends Ability

export var min_dist: int = 1
export var max_dist: int = 1

const _ATTACK_ANIMS = {
	Directions.NORTH: "actor_attack_north",
	Directions.EAST: "actor_attack_east",
	Directions.SOUTH: "actor_attack_south",
	Directions.WEST: "actor_attack_west"
}


func get_range(source_cell: Vector2) -> Array:
	return TileGeometry.cells_in_range(source_cell, min_dist, max_dist)


func is_valid_target(target_cell: Vector2, _source_cell: Vector2) -> bool:
	var other_actor := get_map().get_actor_on_cell(target_cell)
	return other_actor and (other_actor.faction != get_actor().faction)


func get_valid_targets(source_cell: Vector2) -> Array:
	var targets := []

	var ability_range := get_range(source_cell)
	for c in ability_range:
		var cell: Vector2 = c
		if is_valid_target(cell, source_cell):
			targets.append(cell)

	return targets


func start(target: Vector2) -> void:
	var dir := target - get_actor().cell
	var anim: String = _ATTACK_ANIMS[dir]
	get_actor().play_anim(anim)
	yield(get_actor(), "animations_finished")
	emit_signal("finished")
