class_name Skill
extends Resource

enum TargetType { ANY, ANY_ACTOR, ENEMY, ALLY, EMPTY }

export var icon: Texture
export var name := "Skill"
export var description := "Skill description"

export var range_type: Resource
export(TargetType) var target_type := TargetType.ANY

export var aoe_type: Resource

export var skill_effect: Resource


func get_targeting_data(source_cell: Vector2, source_actor: Actor, map: Map) \
		-> TargetingData:
	var target_range := _get_range(source_cell, source_actor, map)
	var valid_targets := []
	var aoe_by_target := {}
	var predicted_damage_by_target := {}
	for c in target_range:
		var target_cell := c as Vector2
		if _is_valid_target(target_cell, source_actor, map):
			valid_targets.append(target_cell)

			var aoe := _get_aoe(target_cell, source_cell, source_actor, map)
			aoe_by_target[target_cell] = aoe

			var predicted_damages := _predict_damages(target_cell, aoe,
					source_cell, source_actor, map)
			predicted_damage_by_target[target_cell] = predicted_damages

	return TargetingData.new(
			source_cell, target_range, valid_targets,
			aoe_by_target, predicted_damage_by_target)


func run(source_actor: Actor, map: Map, target: Vector2) -> void:
	var aoe := _get_aoe(target, source_actor.origin_cell, source_actor, map)
	var effect := skill_effect as SkillEffect
	yield(effect.run(target, aoe, source_actor, map), "completed")


func _get_range(source_cell: Vector2, source_actor: Actor, map: Map) -> Array:
	var skill_range := range_type as SkillRange
	var result := [source_cell]
	if skill_range:
		result = skill_range.get_range(source_cell, source_actor, map)
	return result


# Assumes target_cell is in range
func _is_valid_target(target_cell: Vector2, source_actor: Actor, map: Map) \
		-> bool:
	var result := false

	var actor_on_target := map.get_actor_on_cell(target_cell)

	match target_type:
		TargetType.ANY_ACTOR:
			result = actor_on_target != null
		TargetType.EMPTY:
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


# Assumes target_cell is in range
func _get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var aoe := aoe_type as SkillAOE
	var result := [target_cell]
	if aoe:
		result = aoe.get_aoe(target_cell, source_cell, source_actor, map)
	return result


# Keys are actors. Values are damage amounts.
func _predict_damages(target_cell: Vector2, aoe: Array, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var effect := skill_effect as SkillEffect
	return effect.predict_damage(target_cell, aoe, source_cell,
			source_actor, map)
