class_name SkillAOE, "res://assets/editor/skill_aoe.png"
extends Resource


# Array of Vector2
func get_aoe(target_cell: Vector2, _source_cell: Vector2, _source_actor: Actor,
		_map: Map) -> Array:
	return [target_cell]
