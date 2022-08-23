class_name SkillRange, "res://assets/editor/skill_range.png"
extends Resource

# Array of Vector2
# warning-ignore:unused_argument
func get_range(source_cell: Vector2, source_actor: Actor) -> Array:
	return [source_cell]
