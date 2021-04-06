class_name State
extends Node

# warning-ignore:unused_signal
signal state_change_requested(new_state, data)


func start(_data: Dictionary) -> void:
	pass


func end() -> void:
	pass


func unhandled_input(_event: InputEvent) -> void:
	pass
