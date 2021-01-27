class_name PlayerTurn
extends TurnController

signal waiting_for_input(player_turn, actors)

signal _actor_picked(actor)


func pick_actor(actors: Array) -> Actor:
	emit_signal("waiting_for_input", self, actors)
	var result := yield(self, "_actor_picked") as Actor
	return result


func use_actor(actor: Actor) -> void:
	emit_signal("_actor_picked", actor)
