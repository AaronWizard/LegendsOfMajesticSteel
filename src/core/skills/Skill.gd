tool
class_name Skill, "res://assets/editor/skill.png"
extends Node

enum TargetType { ANY, ANY_ACTOR, ENEMY, ALLY, EMPTY_CELL }

export var icon: Texture
export var skill_name := "Skill"
export var description := "Skill description"
export var energy_cost := 0

export var range_type: Resource
export(TargetType) var target_type := TargetType.ANY

export var use_action_pose := false


func _get_configuration_warning() -> String:
	var result := ""

	if get_child_count() == 0:
		result = "Skills need to have a SkillEffect node"
	elif not get_child(0) is SkillEffect:
		result = "First child is not a SkillEffect"
	else:
		for i in range(1, get_child_count()):
			var child := get_child(i as int)
			if child is SkillEffect:
				result = "Only first skill effect will be used"
				break

	return result


func get_targeting_data(source_cell: Vector2, source_actor: Actor, map: Map) \
		-> TargetingData:
	var target_range := _get_range(source_cell, source_actor, map)

	var valid_targets := []
	var aoe_by_target := {}
	var predicted_damage_by_target := {}
	var predicted_conditions_by_target := {}

	for c in target_range:
		var target_cell := c as Vector2
		if _is_valid_target(target_cell, source_actor, map):
			valid_targets.append(target_cell)

			var aoe := _get_aoe(target_cell, source_cell, source_actor, map)
			aoe_by_target[target_cell] = aoe

			var predicted_damages := _predict_damages(target_cell, source_cell,
					source_actor, map)
			if predicted_damages.size() > 0:
				predicted_damage_by_target[target_cell] = predicted_damages

			var predicted_conditions := _predict_conditions(
					target_cell, source_cell, source_actor, map)
			if predicted_conditions.size() > 0:
				predicted_conditions_by_target[target_cell] \
						= predicted_conditions

	return TargetingData.new(
			source_cell, target_range, valid_targets,
			aoe_by_target, predicted_damage_by_target,
			predicted_conditions_by_target)


func run(source_actor: Actor, map: Map, target: Vector2) -> void:
	if use_action_pose:
		source_actor.pose = Actor.Pose.ACTION

	source_actor.stats.spend_energy(energy_cost)
	_get_effect().run(target, source_actor.origin_cell, source_actor, map)
	yield(_get_effect(), "finished")

	source_actor.reset_pose()


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


func _get_effect() -> SkillEffect:
	return get_child(0) as SkillEffect


# Assumes target_cell is in range
func _get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	if source_cell != source_actor.origin_cell:
		source_actor.virtual_origin_cell = source_cell
	var result := _get_effect().get_aoe(
			target_cell, source_cell, source_actor, map)
	map.reset_actor_virtual_origins()
	return result


# Keys are actors. Values are damage amounts.
func _predict_damages(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	if source_cell != source_actor.origin_cell:
		source_actor.virtual_origin_cell = source_cell
	var result := _get_effect().predict_damage(
			target_cell, source_cell, source_actor, map)
	map.reset_actor_virtual_origins()
	return result


func _predict_conditions(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	if source_cell != source_actor.origin_cell:
		source_actor.virtual_origin_cell = source_cell
	var result := _get_effect().predict_conditions(
			target_cell, source_cell, source_actor, map)
	map.reset_actor_virtual_origins()
	return result
