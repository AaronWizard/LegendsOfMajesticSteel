class_name Player
extends ActorController

signal waiting_for_input(player, actor)


func determine_action(actor: Actor, _map: Map) -> void:
	emit_signal("waiting_for_input", self, actor)


func do_action(action: Action) -> void:
	emit_signal("determined_action", action)
