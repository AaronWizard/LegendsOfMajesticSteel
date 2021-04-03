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


func _run_self(target_cell: Vector2, source_actor: Actor, map: Map) -> void:
	var actor := map.get_actor_on_cell(target_cell)
	var damage := actor.stats.damage_from_attack(source_actor.stats.attack)

	var direction := Vector2.ZERO
	if use_direction:
		direction = actor.center_cell - source_actor.center_cell

	actor.stats.take_damage(damage)

	if actor.is_alive:
		actor.animate_hit(direction)
	else:
		actor.animate_death(direction)

	yield(actor, "animation_finished")
