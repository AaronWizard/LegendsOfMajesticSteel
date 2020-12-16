class_name ProjectileAttackEffect
extends SkillEffect

export var projectile_scene: PackedScene
export var rotate_projectile := false

var _waiter := SignalWaiter.new()


func start(target: Vector2, source_actor: Actor, map: Map) -> void:
	var target_actor := map.get_actor_on_cell(target)

	_waiter.wait_for_signal(source_actor, "attack_finished")

	var dir := source_actor.cell.direction_to(target_actor.cell)
	source_actor.animate_attack(dir, true)
	yield(source_actor, "attack_hit")

	var projectile := projectile_scene.instance() as Projectile
	projectile.start_cell = source_actor.cell
	projectile.end_cell = target
	projectile.rotate_sprite = rotate_projectile
	map.add_effect(projectile)

	yield(projectile, "finished")

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
