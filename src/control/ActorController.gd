class_name ActorController
extends Node

var pauses: bool setget , get_pauses


func get_pauses() -> bool:
	return false


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func determine_action(actor: Actor, map: Map) -> Action:
	print("ActorController: Must implement determine_action()")
	return null
