class_name ShowProjectile
extends Process


var projectile_scene: PackedScene
var map: Map

var start_cell: Vector2
var end_cell: Vector2
var rotate_projectile: bool


func _init(new_projectile_scene: PackedScene, new_map: Map,
		new_start_cell: Vector2, new_end_cell: Vector2,
		new_rotate_projectile: bool) -> void:
	projectile_scene = new_projectile_scene
	map = new_map
	start_cell = new_start_cell
	end_cell = new_end_cell
	rotate_projectile = new_rotate_projectile


func _run_self() -> void:
	var projectile := projectile_scene.instance() as Projectile
	projectile.start_cell = start_cell
	projectile.end_cell = end_cell
	projectile.use_cell_offsets = false
	projectile.rotate_sprite = rotate_projectile

	map.add_effect(projectile)
	yield(projectile, "finished")
