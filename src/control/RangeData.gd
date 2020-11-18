class_name RangeData

var visible_move_range := {} # Set; keys are cells
var move_range := {} # Set; keys are cells

var _walk_grid := AStar2D.new()


func _init(actor: Actor, map: Map) -> void:
	_init_visible_move_range(actor, map)
	_init_move_range(actor, map)
	_init_walk_grid_paths()


func get_walk_path(start: Vector2, end: Vector2) -> Array:
	var result := []

	if (start != end) and move_range.has(start) and move_range.has(end):
		var end_point := _walk_path_point(end)
		if end_point > -1:
			var start_point := _walk_path_point(start)
			assert(start_point > -1)

			result = _walk_grid.get_point_path(start_point, end_point)
			result.pop_front() # Remove starting cell
		assert(result.size() > 0)

	return result


func _init_visible_move_range(actor: Actor, map: Map) -> void:
	var mr := BreadthFirstSearch.find_move_range(actor, map)
	for c in mr:
		var cell := c as Vector2
		visible_move_range[cell] = true


func _init_move_range(actor: Actor, map: Map) -> void:
	for c in visible_move_range:
		var cell: Vector2 = c

		_walk_grid.add_point(
			_walk_grid.get_available_point_id(),
			cell
		)

		if map.actor_can_enter_cell(actor, cell):
			move_range[cell] = true


func _init_walk_grid_paths() -> void:
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
