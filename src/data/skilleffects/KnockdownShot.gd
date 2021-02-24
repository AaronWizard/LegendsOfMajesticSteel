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

	var projectile := _create_projectile(
			source_actor.center_cell + source_actor.cell_offset,
			target_actor.center_cell)

	var projectile_effect = MapEffectProcess.new(projectile, "finished", map)
	projectile_effect.children.append(
		PushActorProcess.new(target_actor, map, source_actor.stats.attack,
			dir_type, distance)
	)
	projectile_effect.children.append(
		ApplyConditionProcess.new(
			target_actor, condition_effect as ConditionEffect)
	)

	var attack := AttackProcess.new(source_actor, dir, true, projectile_effect)

	attack.run()
	yield(attack, "finished")


func _create_projectile(start_cell: Vector2, end_cell: Vector2) -> Projectile:
	var result := projectile_scene.instance() as Projectile
	result.start_cell = start_cell
	result.end_cell = end_cell
	result.use_cell_offsets = false
	result.rotate_sprite = rotate_projectile

	return result
