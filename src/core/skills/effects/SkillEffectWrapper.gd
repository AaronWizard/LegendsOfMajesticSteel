tool
class_name SkillEffectWrapper
extends SkillEffect


func _get_configuration_warning() -> String:
	var result := ""

	if get_child_count() == 0:
		result = "SkillEffectWrapper needs to have a child SkillEffect"
	elif get_child_count() > 1:
		result = "SkillEffectWrapper can only have one child SkillEffect"
	elif not (get_child(0) is SkillEffect):
		result = "Child is not a SkillEffect"

	return result


func get_target_info(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> TargetingData.TargetInfo:
	return _get_child_target_info(target_cell, source_cell, source_actor, map)


func _get_child_target_info(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> TargetingData.TargetInfo:
	return _child_effect().get_target_info(
			target_cell, source_cell, source_actor, map)


func _run_child_effect(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	_child_effect().run(target_cell, source_cell, source_actor, map)
	yield(_child_effect(), "finished")


func _child_effect() -> SkillEffect:
	var result: SkillEffect = null
	if get_child_count() > 0:
		result = get_child(0) as SkillEffect
	return result
