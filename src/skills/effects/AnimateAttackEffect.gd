class_name AnimateAttackEffect
extends SkillEffect

export var target_is_actor := false
export var reduce_lunge := false
export var default_sound := true


func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	var result := []
	if _onhit_effect():
		result = _onhit_effect().get_aoe(
				target_cell, source_cell, source_actor, map)
	return result


func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}
	if _onhit_effect():
		result = _onhit_effect().predict_damage(
				target_cell, source_cell, source_actor, map)
	return result


func _run_self(target_cell: Vector2, source_actor: Actor, map: Map):
	var direction: Vector2
	if target_is_actor:
		var target_actor := map.get_actor_on_cell(target_cell)
		direction = target_actor.center_cell - source_actor.center_cell
	else:
		direction = target_cell - source_actor.origin_cell

	source_actor.animate_attack(direction, reduce_lunge, default_sound)

	if _onhit_effect():
		yield(source_actor, "attack_hit")
		_onhit_effect().run(target_cell, source_actor, map)
		yield(_onhit_effect(), "finished")

	if source_actor.animating:
		yield(source_actor, "animation_finished")


func _onhit_effect() -> SkillEffect:
	var result: SkillEffect = null
	if get_child_count() > 0:
		result = get_child(0) as SkillEffect
	return result
