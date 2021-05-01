class_name AttackTargetedActorEffect, \
		"res://assets/editor/attacktargetedactor_effect.png"
extends SkillEffect

export var use_direction := true


func get_aoe(target_cell: Vector2, _source_cell: Vector2, _source_actor: Actor,
		map: Map) -> Array:
	var actor := map.get_actor_on_cell(target_cell)
	return actor.covered_cells


func predict_damage(target_cell: Vector2, _source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var actor := map.get_actor_on_cell(target_cell)
	var damage := actor.stats.damage_from_attack(source_actor.stats.attack)
	return { actor: -damage }


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	var actor := map.get_actor_on_cell(target_cell)

	var direction := Vector2.ZERO
	if use_direction:
		var end := actor.center_cell
		var start: Vector2
		if source_cell == source_actor.origin_cell:
			start = source_actor.center_cell
		else:
			start = source_cell + Vector2(0.5, 0.5)

		direction = end - start

	actor.stats.take_damage(source_actor.stats.attack, direction)
	if actor.animating:
		yield(actor, "animation_finished")
