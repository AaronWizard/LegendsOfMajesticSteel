class_name BattleStats
extends Node

var finished := false
var move_range := []
var enterable_cells := []

onready var _walk_grid := AStar2D.new()


func start_turn() -> void:
	finished = false

	var map: Map = _get_actor().map as Map
	move_range = BreadthFirstSearch.find_move_range(_get_actor(), map)
	_update_move_range()


func get_walk_path(cell_to: Vector2) -> Array:
	var result := []

	if (cell_to != _get_actor().cell) and (cell_to in enterable_cells):
		var end_point := _walk_path_point(cell_to)
		if end_point > -1:
			var start_cell := _get_actor().cell
			var start_point := _walk_path_point(start_cell)
			assert(start_point > -1)

			result = _walk_grid.get_point_path(start_point, end_point)
			result.pop_front() # Remove starting cell
		assert(result.size() > 0)

	return result


func _get_actor() -> Actor:
	return owner as Actor


func _get_map() -> Map:
	return _get_actor().map

func _update_move_range() -> void:
	enterable_cells.clear()
	_walk_grid.clear()

	for c in move_range:
		var cell: Vector2 = c

		_walk_grid.add_point(
			_walk_grid.get_available_point_id(),
			cell
		)

		if _get_map().actor_can_enter_cell(_get_actor(), cell):
			enterable_cells.append(cell)

	for p in _walk_grid.get_points():
		var point: int = p
		var cell := _walk_grid.get_point_position(point)
		for d in Directions.ALL_DIRECTIONS:
			var dir: Vector2 = d
			var adj_cell := dir + cell

			var adj_point := _walk_path_point(adj_cell)
			if (adj_point > -1) \
					and not _walk_grid.are_points_connected(point, adj_point):
				_walk_grid.connect_points(point, adj_point)


func _walk_path_point(cell: Vector2) -> int:
	var result := _walk_grid.get_closest_point(cell)
	if (result == -1) or (_walk_grid.get_point_position(result) != cell):
		result = -1
	return result
