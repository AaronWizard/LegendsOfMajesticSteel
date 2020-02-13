class_name TurnTaker
extends Node

signal determined_action(action)

func determine_action() -> void:
	print("TurnTaker: Must implement determine_action()")
	emit_signal("determined_action", null)
