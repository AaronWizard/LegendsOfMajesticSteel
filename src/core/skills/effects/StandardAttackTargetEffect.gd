class_name StandardAttackTargetEffect, \
		"res://assets/editor/animateattack_effect.png"
extends SkillEffect


func get_target_info(target_cell: Vector2, _source_cell: Vector2,
		source_actor: Actor, map: Map) -> TargetingData.TargetInfo:
	var attack_skill := source_actor.attack_skill as Skill
	var targeting_data := attack_skill.get_targeting_data(
			source_actor.origin_cell, source_actor, map)
	var result := targeting_data.get_target_info(target_cell)
	if not result:
		result = TargetingData.TargetInfo.new()

	return result


func _run_self(target_cell: Vector2, _source_cell: Vector2, source_actor: Actor,
		map: Map) -> void:
	var attack_skill := source_actor.attack_skill as Skill

	var targeting_data := attack_skill.get_targeting_data(
			source_actor.origin_cell, source_actor, map)
	if targeting_data.valid_targets.has(target_cell):
		yield(attack_skill.run(source_actor, map, target_cell), "completed")
