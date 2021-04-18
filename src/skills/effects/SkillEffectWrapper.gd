class_name SkillEffectWrapper
extends SkillEffect


func _child_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var result := []
	if _child_effect():
		result = _child_effect().get_aoe(
				target_cell, source_cell, source_actor, map)
	return result


func _predict_child_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}
	if _child_effect():
		result = _child_effect().predict_damage(
				target_cell, source_cell, source_actor, map)
	return result


func _run_child_effect(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	if _child_effect():
		_child_effect().run(target_cell, source_cell, source_actor, map)
		yield(_child_effect(), "finished")


func _child_effect() -> SkillEffect:
	var result: SkillEffect = null
	if get_child_count() > 0:
		result = get_child(0) as SkillEffect
	return result
