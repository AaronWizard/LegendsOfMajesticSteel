class_name ShowProjectile
extends Process


var projectile_scene: PackedScene
var map: Map

var start: Rect2
var end: Rect2

var source_actor: Actor


# https://www.youtube.com/watch?v=z3RBOTY771M
static func between_cells(new_projectile_scene: PackedScene, new_map: Map,
		new_start_cell: Vector2, new_end_cell: Vector2) -> ShowProjectile:
	return load("res://src/processes/ShowProjectile.gd").new(
			new_projectile_scene, new_map,
			Rect2(new_start_cell, Vector2.ONE),
			Rect2(new_end_cell, Vector2.ONE))


# https://www.youtube.com/watch?v=z3RBOTY771M
static func between_actors(new_projectile_scene: PackedScene, new_map: Map,
		new_start_actor: Actor, new_end_actor: Actor) -> ShowProjectile:
	return load("res://src/processes/ShowProjectile.gd").new(
			new_projectile_scene, new_map,
			new_start_actor.cell_rect, new_end_actor.cell_rect,
			new_start_actor)


func _init(new_projectile_scene: PackedScene, new_map: Map,
		new_start: Rect2, new_end: Rect2,
		new_source_actor: Actor = null) -> void:
	projectile_scene = new_projectile_scene
	map = new_map

	start = new_start
	end = new_end

	source_actor = new_source_actor


func _run_self() -> void:
	var projectile := projectile_scene.instance() as Projectile
	map.add_effect(projectile)

	if source_actor:
		projectile.start.origin_cell = source_actor.origin_cell
		projectile.start.cell_offset = source_actor.cell_offset
		projectile.start.rect_size = source_actor.rect_size
	else:
		projectile.start.origin_cell = start.position
		projectile.end.rect_size = start.size

	projectile.end.origin_cell = end.position
	projectile.end.rect_size = end.size

	projectile.start_animation()
	yield(projectile, "finished")
