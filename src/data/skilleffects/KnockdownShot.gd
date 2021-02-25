class_name KnockdownShot
extends SkillEffect

export var distance := 1
export var projectile_scene: PackedScene
export var rotate_projectile := false

export var condition_effect: Resource


func run(target_cell: Vector2, _aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var target_actor := map.get_actor_on_cell(target_cell)
	var dir := source_actor.center_cell.direction_to(target_actor.center_cell)
	var dir_type := TileGeometry.direction_from_rect_to_cell( \
			target_cell, source_actor.cell_rect)

	var projectile_effect := ShowProjectile.new(projectile_scene, map,
			source_actor.center_cell, target_actor.center_cell,
			rotate_projectile)
	projectile_effect.children.append(
		PushActor.new(target_actor, map, source_actor.stats.attack,
			dir_type, distance)
	)
	projectile_effect.children.append(
		ApplyCondition.new(
			target_actor, condition_effect as ConditionEffect)
	)

	var attack := AnimateAttack.new(source_actor, dir, true, projectile_effect)

	attack.run()
	yield(attack, "finished")
