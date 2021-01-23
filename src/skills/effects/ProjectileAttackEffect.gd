class_name ProjectileAttackEffect
extends SkillEffect

export var projectile_scene: PackedScene
export var rotate_projectile := false

var _waiter := SignalWaiter.new()


func start(target_cell: Vector2, source_actor: Actor, map: Map) -> void:
	var target_actor := map.get_actor_on_cell(target_cell)
	var dir := source_actor.center_cell.direction_to(target_actor.center_cell)

	var attack := AttackProcess.new(
			target_actor, map, source_actor.stats.attack, dir)

	_waiter.wait_for_signal(source_actor, "attack_finished")
	source_actor.animate_attack(dir, true)
	yield(source_actor, "attack_hit")

	var projectile := _create_projectile(
			source_actor.center_cell + source_actor.cell_offset,
			target_actor.center_cell)
	map.add_effect(projectile)
	yield(projectile, "finished")

	attack.run()
	yield(attack, "finished")

	if _waiter.waiting:
		yield(_waiter, "finished")

	emit_signal("finished")


func _create_projectile(start_cell: Vector2, end_cell: Vector2) -> Projectile:
	var result := projectile_scene.instance() as Projectile
	result.start_cell = start_cell
	result.end_cell = end_cell
	result.use_cell_offsets = false
	result.rotate_sprite = rotate_projectile

	return result
