class_name Ability
extends Resource

enum TargetType { ANY, ANY_ACTOR, ENEMY, ALLY }

export var name := "Ability"

export var range_type: Resource
export(TargetType) var target_type := TargetType.ANY

export var aoe_type: Resource

export var ability_effect: Resource


func get_range(source_cell: Vector2, source_actor: Actor, map: Map) -> Array:
	var result := [source_cell]
	if _get_range_type():
		result = _get_range_type().get_range(source_cell, source_actor, map)
	return result


# Assumes target_cell is in range
func is_valid_target(target_cell: Vector2, source_actor: Actor, map: Map) \
		-> bool:
	var result := false

	match target_type:
		TargetType.ANY_ACTOR:
			result = map.get_actor_on_cell(target_cell) != null
		TargetType.ENEMY, TargetType.ALLY:
			var other_actor := map.get_actor_on_cell(target_cell)
			if other_actor:
				match target_type:
					TargetType.ENEMY:
						result = other_actor.faction != source_actor.faction
					_:
						assert(target_type == TargetType.ALLY)
						result = other_actor.faction == source_actor.faction
			else:
				assert(target_type == TargetType.ANY)
				result = false
		_:
			result = true

	return result


# Assumes target_cell is in range
func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var result := [target_cell]
	if _get_aoe_type():
		result = _get_aoe_type().get_aoe(target_cell, source_cell, source_actor,
				map)
	return result


func _get_range_type() -> AbilityRange:
	return range_type as AbilityRange


func _get_aoe_type() -> AbilityAOE:
	return aoe_type as AbilityAOE
