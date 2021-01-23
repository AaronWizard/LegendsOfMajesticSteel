class_name MeleeAttackEffect
extends SkillEffect

var _waiter := SignalWaiter.new()


func start(target_cell: Vector2, source_actor: Actor, map: Map) -> void:
	var dir := target_cell - source_actor.origin_cell
	var target_actor := map.get_actor_on_cell(target_cell)

	var attack := AttackProcess.new(
			target_actor, map, source_actor.stats.attack, dir)

	_waiter.wait_for_signal(source_actor, "attack_finished")
	source_actor.animate_attack(dir)
	yield(source_actor, "attack_hit")

	attack.run()
	yield(attack, "finished")

	if _waiter.waiting:
		yield(_waiter, "finished")

	emit_signal("finished")
