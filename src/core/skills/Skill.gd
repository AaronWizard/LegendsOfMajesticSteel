tool
class_name Skill, "res://assets/editor/skill.png"
extends Node

enum TargetType { ANY, ANY_ACTOR, ENEMY, ALLY, EMPTY_CELL, ENTERABLE_CELL }

export var icon: Texture
export var skill_name := "Skill"
export var description := "Skill description"

export var max_cooldown := 1

export var range_type: Resource
export(TargetType) var target_type := TargetType.ANY

export var use_action_pose := false

var is_attack := false

var current_cooldown := 0


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


func start_battle() -> void:
	current_cooldown = max_cooldown


func charge() -> void:
	if current_cooldown > 0:
		current_cooldown -= 1


func get_targeting_data(source_cell: Vector2, source_actor: Actor, map: Map) \
		-> TargetingData:
	var target_range := _get_range(source_cell, source_actor, map)

	var valid_targets := []
	var infos_by_target := {}

	for c in target_range:
		var target_cell := c as Vector2
		if _is_valid_target(target_cell, source_actor, map):
			valid_targets.append(target_cell)

			if source_cell != source_actor.origin_cell:
				source_actor.virtual_origin_cell = source_cell

			var target_info := _get_effect().get_target_info(target_cell,
					source_cell, source_actor, map)
			infos_by_target[target_cell] = target_info

			map.reset_actor_virtual_origins()

	return TargetingData.new(
			source_cell, target_range, valid_targets, infos_by_target)


func run(source_actor: Actor, map: Map, target: Vector2) -> void:
	if use_action_pose:
		source_actor.set_pose(Actor.Pose.ACTION)

	_get_effect().run(target, source_actor.origin_cell, source_actor, map)
	yield(_get_effect(), "finished")

	source_actor.reset_pose()

	if is_attack:
		source_actor.charge_skills()
	else:
		current_cooldown = max_cooldown


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


func _get_effect() -> SkillEffect:
	return get_child(0) as SkillEffect
