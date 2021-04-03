class_name ProjectileEffect, "res://assets/editor/projectile_effect.png"
extends SkillEffect

export var projectile_scene: PackedScene
export var target_is_actor := false


func _run_self(target_cell: Vector2, source_actor: Actor, map: Map):
	var projectile := projectile_scene.instance() as Projectile
	map.add_effect(projectile)

	projectile.start.copy(source_actor)
	if target_is_actor:
		var target_actor := map.get_actor_on_cell(target_cell)
		projectile.end.copy(target_actor)
	else:
		projectile.end.origin_cell = target_cell

	projectile.start_animation()
	yield(projectile, "finished")
