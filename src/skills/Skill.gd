class_name Skill
extends Node

enum TargetType { ANY, ANY_ACTOR, ENEMY, ALLY, EMPTY_CELL }

export var icon: Texture
export var skill_name := "Skill"
export var description := "Skill description"

export var range_type: Resource
export(TargetType) var target_type := TargetType.ANY


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

			var predicted_damages := _predict_damages(target_cell, source_cell,
					source_actor, map)
			predicted_damage_by_target[target_cell] = predicted_damages

	return TargetingData.new(
			source_cell, target_range, valid_targets,
			aoe_by_target, predicted_damage_by_target)


func run(source_actor: Actor, map: Map, target: Vector2) -> void:
	for e in get_children():
		var effect := e as SkillEffect
		yield(effect.run(target, source_actor, map), "completed")


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


# Assumes target_cell is in range
func _get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var result := {}
	for e in get_children():
		var effect := e as SkillEffect
		var aoe := effect.get_aoe(target_cell, source_cell, source_actor, map)
		for c in aoe:
			var cell := c as Vector2
			result[cell] = true
	return result.keys()


# Keys are actors. Values are damage amounts.
func _predict_damages(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}
	for e in get_children():
		var effect := e as SkillEffect
		var effect_damages := effect.predict_damage(
				target_cell, source_cell, source_actor, map)
		for a in effect_damages:
			var actor := a as Actor
			var damage := effect_damages[actor] as int
			if not result.has(actor):
				result[actor] = 0
			result[actor] += damage
	return result
