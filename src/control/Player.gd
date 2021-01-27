class_name Player
extends ActorController

signal waiting_for_input(player, actor)

signal _action_picked(action)


func determine_action(actor: Actor, _map: Map) -> Action:
	emit_signal("waiting_for_input", self, actor)
	var result := yield(self, "_action_picked") as Action
	return result


func do_action(action: Action) -> void:
	emit_signal("_action_picked", action)
