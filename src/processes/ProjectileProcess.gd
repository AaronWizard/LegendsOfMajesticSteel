class_name ProjectileProcess
extends Process

var projectile: Projectile
var map: Map

func _init(new_projectile: Projectile, new_map: Map) -> void:
	projectile = new_projectile
	map = new_map


func _run_self() -> void:
	map.add_effect(projectile)
	yield(projectile, "finished")
