class_name TurnController
extends Node

signal actor_picked(actor)


# warning-ignore:unused_argument
func pick_actor(actors: Array, control: BattleInterface) -> void:
	print("TurnController: Must implement pick_actor()")
	emit_signal("actor_picked", actors[0])
