class_name SkillEffect
extends Resource

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func predict_damage(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> Dictionary:
	return {}


# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func run(target_cell: Vector2, aoe: Array, source_actor: Actor, map: Map) \
		-> void:
	print("SkillEffect must implement start()")
