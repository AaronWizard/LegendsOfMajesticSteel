class_name ShowProjectile
extends Process


var projectile_scene: PackedScene
var map: Map

var start_cell: Vector2
var end_cell: Vector2

var source_actor: Actor
var _using_target_actor: bool


# https://www.youtube.com/watch?v=z3RBOTY771M
static func between_cells(new_projectile_scene: PackedScene, new_map: Map,
		new_start_cell: Vector2, new_end_cell: Vector2) -> ShowProjectile:
	return load("res://src/processes/ShowProjectile.gd").new(
			new_projectile_scene, new_map, new_start_cell, new_end_cell)


# https://www.youtube.com/watch?v=z3RBOTY771M
static func between_actors(new_projectile_scene: PackedScene, new_map: Map,
		new_start_actor: Actor, new_end_actor: Actor) -> ShowProjectile:
	return load("res://src/processes/ShowProjectile.gd").new(
			new_projectile_scene, new_map, Vector2.ZERO, Vector2.ZERO,
			new_start_actor, new_end_actor)


func _init(new_projectile_scene: PackedScene, new_map: Map,
		new_start_cell: Vector2, new_end_cell: Vector2,
		new_source_actor: Actor = null, new_target_actor: Actor = null) -> void:
	projectile_scene = new_projectile_scene
	map = new_map

	if new_source_actor:
		start_cell = new_source_actor.center_cell
	else:
		start_cell = new_start_cell

	if new_target_actor:
		end_cell = new_target_actor.center_cell
		_using_target_actor = true
	else:
		end_cell = new_end_cell
		_using_target_actor = false

	source_actor = new_source_actor


func _run_self() -> void:
	var projectile := projectile_scene.instance() as Projectile

	projectile.start_cell = start_cell
	if source_actor:
		projectile.start_cell += source_actor.cell_offset
		projectile.start_offset = false

	projectile.end_cell = end_cell
	if _using_target_actor:
		projectile.end_offset = false

	map.add_effect(projectile)
	yield(projectile, "finished")
