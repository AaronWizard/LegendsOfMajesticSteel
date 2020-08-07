class_name ActorController
extends Node

signal determined_action(action)

var pauses := false setget , get_pauses


func _ready() -> void:
	var parent := get_parent() as Actor
	if parent:
		parent.controller = self


func get_pauses() -> bool:
	return false


# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func determine_action(actor: Actor, map: Map, range_data: RangeData,
		interface: BattleInterface) -> void:
	print("ActorController: Must implement determine_action()")
	emit_signal("determined_action", null)
