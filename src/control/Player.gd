class_name Player
extends ActorController

signal waiting_for_input(player)


func determine_action(_actor: Actor, _map: Map, _range_data: RangeData) -> void:
	emit_signal("waiting_for_input", self)


func do_action(action: Action) -> void:
	emit_signal("determined_action", action)
