class_name AddStatModifierToTargetEffect, \
		"res://assets/editor/add_status_effect.png"
extends SkillEffect

export var stat_mod: Resource


func get_target_info(target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, map: Map) -> TargetingData.TargetInfo:
	var result := TargetingData.TargetInfo.new()

	var actor := map.get_actor_on_cell(target_cell)
	if actor:
		for c in actor.covered_cells:
			result.aoe[c] = true
		#var effect := condition_effect as ConditionDefinition
		#result.predicted_conditions[actor] = [effect]

	return result


func _run_self(target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, map: Map) -> void:
	var actor := map.get_actor_on_cell(target_cell)
	if actor:
		var mod_def := stat_mod as StatModifierDefinition
		var mod := StatModifier.new(mod_def)

		actor.stats.add_stat_mod(mod)
