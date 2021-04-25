class_name AnimateAttackEffect, "res://assets/editor/animateattack_effect.png"
extends SkillEffectWrapper

export var target_is_actor := false
export var reduce_lunge := false
export var default_sound := true


func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	return _child_aoe(target_cell, source_cell, source_actor, map)


func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	return _predict_child_damage(target_cell, source_cell, source_actor, map)


func predict_conditions(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	return _predict_child_conditions(target_cell, source_cell,
			source_actor, map)


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map):
	var direction: Vector2
	if target_is_actor:
		var target_actor := map.get_actor_on_cell(target_cell)
		direction = target_actor.center_cell - source_actor.center_cell
	else:
		direction = target_cell - source_actor.origin_cell

	source_actor.animate_attack(direction, reduce_lunge, default_sound)

	if _child_effect():
		yield(source_actor, "attack_hit")

		var child_state = _run_child_effect(target_cell, source_cell,
				source_actor, map)
		if child_state is GDScriptFunctionState:
			yield(child_state, "completed")

	if source_actor.animating:
		yield(source_actor, "animation_finished")
