class_name BattleStats
extends Node

var walk_cells := []


func find_paths() -> void:
	var map: Map = _get_actor().map as Map
	walk_cells = BreadthFirstSearch.find_move_range(_get_actor(), map)


func _get_actor() -> Actor:
	return owner as Actor
