class_name AbilityEffect
extends Resource

signal finished


# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func start(source_actor: Actor, map: Map, target: Vector2) -> void:
	print("AbilityEffect must implement start()")
	emit_signal("finished")
