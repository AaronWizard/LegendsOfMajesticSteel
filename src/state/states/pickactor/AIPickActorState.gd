class_name AIPickActorState
extends PickActorState

var _actor_picker := AIPickActor.new()


func _get_faction() -> int:
	return Actor.Faction.ENEMY


func _choose_actor() -> void:
	var actor := _actor_picker.pick_actor(_actors, _game.map)
	_pick_actor(actor)
