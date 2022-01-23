class_name TurnManager
extends Node

signal round_started

var ordered_actors: Array setget , get_ordered_actors

var _actors := []
var _turn_index := -1


func roll_initiative(actors: Array) -> void:
	clear()
	_actors = actors.duplicate()
	_actors.sort_custom(self, "_compare_actors")


func clear() -> void:
	_actors.clear()
	_turn_index = -1


func get_ordered_actors() -> Array:
	return ordered_actors.duplicate()


func next_actor() -> Actor:
	_turn_index = (_turn_index + 1) % _actors.size()
	if _turn_index == 0:
		emit_signal("round_started")

	return _actors[_turn_index] as Actor


func remove_actor(actor: Actor) -> int:
	var index := _actors.find(actor)
	assert(index > -1)
	_actors.remove(index)
	if index < _turn_index:
		_turn_index -= 1

	return index


# Actors have the following order:
# - Actors with higher agilities go first
# - Player actors go first
# - Actors earlier in the scene tree go first
func _compare_actors(a: Actor, b: Actor) -> bool:
	return (a.stats.agility > b.stats.agility) \
			or ((a.faction == Actor.Faction.PLAYER) \
				and (a.faction != b.faction)) \
			or (a.get_index() < b.get_index())
