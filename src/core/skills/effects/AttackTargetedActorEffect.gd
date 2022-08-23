class_name AttackTargetedActorEffect, \
		"res://assets/editor/attacktargetedactor_effect.png"
extends SkillEffect

export var use_direction := true


func get_target_info(target_cell: Vector2, _source_cell: Vector2,
		source_actor: Actor) -> TargetingData.TargetInfo:
	var result := TargetingData.TargetInfo.new()

	var map := source_actor.map as Map
	var actor := map.get_actor_on_cell(target_cell)
	if actor:
		for c in actor.covered_cells:
			result.aoe[c] = true

		var damage := actor.stats.damage_from_attack(source_actor.stats.attack)
		result.predicted_damage[actor] = -damage

	return result


func _run_self(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor) -> void:
	var map := source_actor.map as Map
	var actor := map.get_actor_on_cell(target_cell)
	if actor:
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
