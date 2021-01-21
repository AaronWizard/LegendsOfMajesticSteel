class_name Skill
extends Resource

enum TargetType { ANY, ANY_ACTOR, ENEMY, ALLY }

signal finished

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
	for c in target_range:
		var cell := c as Vector2
		if is_valid_target(cell, source_actor, map):
			valid_targets.append(cell)
	return TargetingData.new(source_cell, target_range, valid_targets)


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


func start(source_actor: Actor, map: Map, target: Vector2) -> void:
	_get_effect().start(target, source_actor, map)
	yield(_get_effect(), "finished")
	emit_signal("finished")


func _get_range_type() -> SkillRange:
	return range_type as SkillRange


func _get_aoe() -> SkillAOE:
	return aoe_type as SkillAOE


func _get_effect() -> SkillEffect:
	return skill_effect as SkillEffect
