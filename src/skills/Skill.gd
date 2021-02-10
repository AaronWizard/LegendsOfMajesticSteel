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
	var target_range := get_range(source_cell, source_actor, map)
	var valid_targets := []
	var aoe_by_target := {}
	for c in target_range:
		var target_cell := c as Vector2
		if is_valid_target(target_cell, source_actor, map):
			valid_targets.append(target_cell)
			var aoe := get_aoe(target_cell, source_cell, source_actor, map)
			aoe_by_target[target_cell] = aoe
	return TargetingData.new(
			source_cell, target_range, valid_targets, aoe_by_target)


func get_range(source_cell: Vector2, source_actor: Actor, map: Map) -> Array:
	var result := [source_cell]
	if _get_range_type():
		result = _get_range_type().get_range(source_cell, source_actor, map)
	return result


# Assumes target_cell is in range
func is_valid_target(target_cell: Vector2, source_actor: Actor, map: Map) \
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
func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var result := [target_cell]
	if _get_aoe():
		result = _get_aoe().get_aoe(
				target_cell, source_cell, source_actor, map)
	return result


# Keys are actors. Values are damage amounts.
func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	return _get_effect().predict_damage(
			target_cell, source_cell, source_actor, map)


func run(source_actor: Actor, map: Map, target: Vector2) -> void:
	var aoe := get_aoe(target, source_actor.origin_cell, source_actor, map)
	yield(_get_effect().run(target, aoe, source_actor, map), "completed")


func _get_range_type() -> SkillRange:
	return range_type as SkillRange


func _get_aoe() -> SkillAOE:
	return aoe_type as SkillAOE


func _get_effect() -> SkillEffect:
	return skill_effect as SkillEffect
