class_name SkillEffect
extends Resource

# Array of Vector2
func get_aoe(_target_cell: Vector2, _source_cell: Vector2, _source_actor: Actor,
		_map: Map) -> Array:
	return []


# Keys are actors, values are ints
# Negative values are damage, positive values are healing
func predict_damage(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, _map: Map) -> Dictionary:
	return {}


func run(_target_cell: Vector2, _source_actor: Actor, _map: Map) -> void:
	push_warning("SkillEffect mus implement run()")
