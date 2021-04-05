class_name AddConditionToTargetEffect, "res://assets/editor/add_condition_effect.png"
extends SkillEffect


export var condition_effect: Resource


func get_aoe(target_cell: Vector2, _source_cell: Vector2, _source_actor: Actor,
		map: Map) -> Array:
	var actor := map.get_actor_on_cell(target_cell)
	return actor.covered_cells


func _run_self(target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, map: Map) -> void:
	var actor := map.get_actor_on_cell(target_cell)
	if actor:
		var ce := condition_effect as ConditionEffect
		actor.add_condition(Condition.new(ce))
