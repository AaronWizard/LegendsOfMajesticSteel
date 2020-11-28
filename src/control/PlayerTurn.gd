class_name PlayerTurn
extends TurnController

signal waiting_for_input(player_turn, actors)


func pick_actor(actors: Array) -> void:
	emit_signal("waiting_for_input", self, actors)


func use_actor(actor: Actor) -> void:
	emit_signal("actor_picked", actor)
