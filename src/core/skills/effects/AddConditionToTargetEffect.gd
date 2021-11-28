class_name AddConditionToTargetEffect, \
		"res://assets/editor/add_condition_effect.png"
extends SkillEffect

export var condition_effect: Resource


func get_target_info(target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, map: Map) -> TargetingData.TargetInfo:
	var result := TargetingData.TargetInfo.new()

	var actor := map.get_actor_on_cell(target_cell)
	if actor:
		for c in actor.covered_cells:
			result.aoe[c] = true
		var effect := condition_effect as ConditionDefinition
		result.predicted_conditions[actor] = [effect]

	return result


func _run_self(target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, map: Map) -> void:
	var actor := map.get_actor_on_cell(target_cell)
	if actor:
		var ce := condition_effect as ConditionDefinition
		actor.stats.add_condition(Condition.new(ce))
