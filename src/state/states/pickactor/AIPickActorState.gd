class_name AIPickActorState
extends PickActorState

const _PAUSE_TIME := 0.4

var _actor_picker := AIPickActor.new()


func _get_faction() -> int:
	return Actor.Faction.ENEMY


func _choose_actor() -> void:
	var actor := _actor_picker.pick_actor(_actors, _game.map)
	_pick_actor(actor)


func _pick_actor(actor: Actor) -> void:
	_game.start_turn(actor)
	yield(get_tree().create_timer(_PAUSE_TIME), "timeout")
	emit_signal("state_change_requested", _turn_start_state)
