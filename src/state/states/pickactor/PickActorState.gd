class_name PickActorState
extends GameState

export var turn_start_state_path: NodePath

var _actors: Array

onready var _turn_start_state := get_node(turn_start_state_path) as State


func start(_data: Dictionary) -> void:
	var faction := _get_faction()
	_actors = _game.get_active_actors(faction)
	assert(_actors.size() > 0)

	_game.interface.gui.can_cancel = _actors.size() > 1

	if _actors.size() == 1:
		call_deferred("_pick_actor", _actors[0])
	else:
		call_deferred("_choose_actor")


func end() -> void:
	_actors.clear()


func _get_faction() -> int:
	push_warning("PickActorState: Need to implement _get_faction()")
	return Actor.Faction.ENEMY


func _pick_actor(actor: Actor) -> void:
	_game.start_turn(actor)
	emit_signal("state_change_requested", _turn_start_state)


func _choose_actor() -> void:
	push_warning("PickActorState: Need to implement _choose_actor()")
