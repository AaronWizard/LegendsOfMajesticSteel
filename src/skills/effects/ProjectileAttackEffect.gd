class_name ProjectileAttackEffect
extends SkillEffect

export var projectile_scene: PackedScene
export var rotate_projectile := false


func run(target_cell: Vector2, _aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var target_actor := map.get_actor_on_cell(target_cell)
	var dir := source_actor.center_cell.direction_to(target_actor.center_cell)

	var projectile_effect := ShowProjectile.new(projectile_scene, map,
			Vector2.ZERO, Vector2.ZERO, source_actor, target_actor)
	projectile_effect.children.append(
		DamageActor.new(
			target_actor, map, source_actor.stats.attack, dir
		)
	)

	var attack := AnimateAttack.new(source_actor, dir, true, projectile_effect)

	attack.run()
	yield(attack, "finished")
