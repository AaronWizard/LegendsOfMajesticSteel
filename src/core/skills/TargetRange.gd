class_name TargetRange, "res://assets/editor/skill_range.png"
extends Resource

enum TargetType { ANY, ANY_ACTOR, ENEMY, ALLY, EMPTY_CELL, ENTERABLE_CELL }

export(TargetType) var target_type := TargetType.ANY


# {
#    full = Array of Vector2,
#    valid = Array of Vector2
# }
func get_ranges(source_cell: Vector2, source_actor: Actor) -> Dictionary:
	var full_range := get_full_range(source_cell, source_actor)
	var valid_range := _valid_range(full_range, source_actor)

	return {
		full = full_range,
		valid = valid_range
	}


# Array of Vector2
# warning-ignore:unused_argument
func get_full_range(source_cell: Vector2, source_actor: Actor) -> Array:
	push_warning("TargetRange: Should override get_full_range")
	return [source_cell]


func _valid_range(full_range: Array, source_actor: Actor) -> Array:
	var result := []
	for c in full_range:
		var target_cell := c as Vector2
		if _is_valid_target(target_cell, source_actor):
			result.append(target_cell)
	return result


func _is_valid_target(target_cell: Vector2, source_actor: Actor) -> bool:
	var result := false

	var map := source_actor.map as Map
	if target_type == TargetType.ENTERABLE_CELL:
		result = map.actor_can_enter_cell(source_actor, target_cell)
	else:
		var actor_on_target := map.get_actor_on_cell(target_cell)

		match target_type:
			TargetType.ANY_ACTOR:
				result = actor_on_target != null
			TargetType.EMPTY_CELL:
				result = actor_on_target == null
			TargetType.ENEMY, TargetType.ALLY:
				if actor_on_target:
					match target_type:
						TargetType.ENEMY:
							result = actor_on_target.faction \
									!= source_actor.faction
						_:
							assert(target_type == TargetType.ALLY)
							result = actor_on_target.faction \
									== source_actor.faction
				else:
					result = false
			_:
				assert(target_type == TargetType.ANY)
				result = true

	return result
