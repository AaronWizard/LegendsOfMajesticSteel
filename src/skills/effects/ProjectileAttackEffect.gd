class_name ProjectileAttackEffect
extends SkillEffect

export var projectile_scene: PackedScene
export var rotate_projectile := false


func predict_damage(_target_cell: Vector2, aoe: Array, _source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	return SkillEffectsUtil.predict_standard_damage(aoe, source_actor, map)


func run(target_cell: Vector2, _aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var target_actor := map.get_actor_on_cell(target_cell)
	var dir := source_actor.center_cell.direction_to(target_actor.center_cell)

	var projectile_effect := ShowProjectile.between_actors(
			projectile_scene, map, source_actor, target_actor)
	projectile_effect.children.append(
		DamageActor.new(
			target_actor, map, source_actor.stats.attack, dir
		)
	)

	var attack := AnimateAttack.new(projectile_effect, source_actor, dir,
			true, false)

	attack.run()
	yield(attack, "finished")
