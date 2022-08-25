tool
class_name Skill, "res://assets/editor/skill.png"
extends Node



export var icon: Texture
export var skill_name := "Skill"
export var description := "Skill description"

export var max_cooldown := 1

export var range_type: Resource

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


func get_targeting_data(source_cell: Vector2, source_actor: Actor) \
		-> TargetingData:
	var full_range := [source_cell]
	var valid_range := [source_cell]

	var skill_range := range_type as TargetRange
	if skill_range:
		var ranges := skill_range.get_ranges(source_cell, source_actor)
		full_range = ranges.full as Array
		valid_range = ranges.valid as Array

	var infos_by_target := {}

	for c in valid_range:
		var target_cell := c as Vector2

		if source_cell != source_actor.origin_cell:
			source_actor.virtual_origin_cell = source_cell

		var target_info := _get_effect().get_target_info(target_cell,
				source_cell, source_actor)
		infos_by_target[target_cell] = target_info

		(source_actor.map as Map).reset_actor_virtual_origins()

	return TargetingData.new(
			source_cell, full_range, valid_range, infos_by_target)


func run(source_actor: Actor, target: Vector2) -> void:
	if use_action_pose:
		source_actor.set_pose(Actor.Pose.ACTION)

	_get_effect().run(target, source_actor.origin_cell, source_actor)
	yield(_get_effect(), "finished")

	source_actor.reset_pose()

	if is_attack:
		source_actor.charge_skills()
	else:
		current_cooldown = max_cooldown


func _get_effect() -> SkillEffect:
	return get_child(0) as SkillEffect
