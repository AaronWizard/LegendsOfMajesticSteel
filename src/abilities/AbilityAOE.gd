class_name AbilityAOE
extends Resource


# Array of Vector2
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func get_aoe(target_cell: Vector2, source_cell: Vector2, source_actor: Actor,
		map: Map) -> Array:
	return [target_cell]
