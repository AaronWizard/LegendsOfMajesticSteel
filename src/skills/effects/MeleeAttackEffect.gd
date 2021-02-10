class_name MeleeAttackEffect
extends SkillEffect

var _waiter := SignalWaiter.new()


func run(target_cell: Vector2, _aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var target_actor := map.get_actor_on_cell(target_cell)
	var dir := target_actor.center_cell - source_actor.center_cell

	var attack := AttackProcess.new(
			target_actor, map, source_actor.stats.attack, dir)

	_waiter.wait_for_signal(source_actor, "attack_finished")
	source_actor.animate_attack(dir)
	yield(source_actor, "attack_hit")

	yield(attack.run(), "completed")

	if _waiter.waiting:
		yield(_waiter, "finished")
