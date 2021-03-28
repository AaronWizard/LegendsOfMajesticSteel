class_name KnockdownShot
extends SkillEffect

export var distance := 1
export var projectile_scene: PackedScene
export var rotate_projectile := false

export var condition_effect: Resource


func predict_damage(target_cell: Vector2, _aoe: Array, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	var result := {}

	var target_actor := map.get_actor_on_cell(target_cell)
	var direction := TileGeometry.direction_from_rect_to_cell( \
			target_cell, source_actor.get_cell_rect_at_cell(source_cell))

	var real_distance := PushActor.get_real_distance(target_actor, map,
		direction, distance)
	var blocking_actors := PushActor.get_blocking_actors(target_actor, map,
			direction, real_distance)

	var damage: int
	if real_distance < distance:
		damage = target_actor.stats.damage_from_attack(
				source_actor.stats.attack * 2)
	else:
		damage = target_actor.stats.damage_from_attack(
				source_actor.stats.attack)
	result[target_actor] = -damage

	for a in blocking_actors:
		var other_actor := a as Actor
		result[a] = -other_actor.stats.damage_from_attack(
				source_actor.stats.attack)

	return result


func run(target_cell: Vector2, _aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	var target_actor := map.get_actor_on_cell(target_cell)
	var dir := source_actor.center_cell.direction_to(target_actor.center_cell)
	var dir_type := TileGeometry.direction_from_rect_to_cell( \
			target_cell, source_actor.cell_rect)

	var projectile_effect := ShowProjectile.between_actors(
			projectile_scene, map, source_actor, target_actor)
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
