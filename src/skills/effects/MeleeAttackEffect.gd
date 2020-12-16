class_name MeleeAttackEffect
extends SkillEffect

var _waiter := SignalWaiter.new()


func start(target: Vector2, source_actor: Actor, map: Map) -> void:
	var dir := target - source_actor.cell
	var target_actor := map.get_actor_on_cell(target)

	_waiter.wait_for_signal(source_actor, "attack_finished")

	source_actor.animate_attack(dir)
	yield(source_actor, "attack_hit")

	target_actor.battle_stats.modify_stamina(-source_actor.stats.attack)

	if target_actor.battle_stats.is_alive:
		_waiter.wait_for_signal(target_actor, "stamina_animation_finished")
		_waiter.wait_for_signal(target_actor, "hit_reaction_finished")
		target_actor.animate_hit(dir)
	else:
		target_actor.animate_death(dir)
		yield(target_actor, "died")

	if _waiter.waiting:
		yield(_waiter, "finished")

	emit_signal("finished")
