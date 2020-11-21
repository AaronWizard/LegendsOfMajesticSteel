class_name ProjectileAttackEffect
extends AbilityEffect

export var projectile_scene: PackedScene
export var rotate_projectile := false

var _projectile: Projectile

func start(target: Vector2, source_actor: Actor, map: Map) -> void:
	var target_actor := map.get_actor_on_cell(target)

	_projectile = projectile_scene.instance() as Projectile
	_projectile.start_cell = source_actor.cell
	_projectile.end_cell = target
	_projectile.rotate_sprite = rotate_projectile
	# warning-ignore:return_value_discarded
	_projectile.connect("finished", self, "_projectile_hit",
			[target_actor, source_actor])
	map.add_effect(_projectile)


func _projectile_hit(target: Actor, source: Actor) \
		-> void:
	var dir := source.cell.direction_to(target.cell).normalized()

	target.battle_stats.modify_stamina(-source.stats.attack)
	if target.battle_stats.is_alive:
		target.animate_hit(dir)
		yield(target, "hit_reaction_finished")
	else:
		target.play_death_anim(Directions.NORTH)
		yield(target, "died")

	emit_signal("finished")
