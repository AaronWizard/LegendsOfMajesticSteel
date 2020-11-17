class_name AbilityEffect
extends Resource

signal finished


# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func start(target: Vector2, source_actor: Actor, map: Map) -> void:
	print("AbilityEffect must implement start()")
	emit_signal("finished")
