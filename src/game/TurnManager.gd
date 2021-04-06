class_name TurnManager
extends Node

signal round_started

var turn_order: Array setget , get_turn_order

var _turn_order := []
var _turn_index := 0


func roll_initiative(actors: Array) -> void:
	_turn_order.clear()
	_turn_index = 0

	for a in actors:
		var actor := a as Actor
		_turn_order.append(actor.faction)


func get_turn_order() -> Array:
	return _turn_order.duplicate()


func next_faction() -> int:
	return _turn_order[_turn_index]


func advance_turn() -> void:
	_turn_index = (_turn_index + 1) % _turn_order.size()
	if _turn_index == 0:
		emit_signal("round_started")


func remove_actor(actor: Actor) -> int:
	var index: int

	if actor.round_finished:
		index = _turn_order.rfind(actor.faction, _turn_index)
	else:
		index = _turn_order.rfind(actor.faction)

	if index > -1:
		_turn_order.remove(index)
		if index < _turn_index:
			_turn_index -= 1

	return index
