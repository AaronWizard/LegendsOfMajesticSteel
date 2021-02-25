class_name MeleeAttackEffect
extends SkillEffect


func run(target_cell: Vector2, _aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var target_actor := map.get_actor_on_cell(target_cell)
	var direction := target_actor.center_cell - source_actor.center_cell

	var attack := AttackProcess.new(
		source_actor, direction, false,
		DamageActor.new(
			target_actor, map, source_actor.stats.attack, direction
		)
	)

	attack.run()
	yield(attack, "finished")
