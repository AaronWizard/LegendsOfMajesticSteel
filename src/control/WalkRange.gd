class_name WalkRange

var origin_cell: Vector2

# Cells the actor can actually occupy
var _true_move_range: Dictionary

# Includes cells outside the actor's true move range but would be covered by
# the actor if it's a multi-tile actor. Visible cells are keys and their
# corresponding origin cells are the values.
var _visible_move_range: Dictionary

var _walk_grid: AStar2D


func _init(new_origin_cell: Vector2, new_true_move_range: Dictionary,
		new_visible_move_range: Dictionary, new_walk_grid: AStar2D) -> void:
	origin_cell = new_origin_cell
	_true_move_range = new_true_move_range
	_visible_move_range = new_visible_move_range
	_walk_grid = new_walk_grid


static func walk_path_point(walk_grid: AStar2D, cell: Vector2) -> int:
	var result := walk_grid.get_closest_point(cell)
	if (result == -1) or (walk_grid.get_point_position(result) != cell):
		result = -1
	return result


func get_visible_move_range() -> Array:
	return _visible_move_range.keys()


func get_move_range() -> Array:
	return _true_move_range.keys()


func get_walk_path(start: Vector2, end: Vector2) -> Array:
	var result := []

	if _true_move_range.has(start) and _visible_move_range.has(end):
		var true_end := _visible_move_range[end] as Vector2
		if (start != true_end) and _true_move_range.has(true_end):
			var end_point := _walk_path_point(true_end)
			if end_point > -1:
				var start_point := _walk_path_point(start)
				assert(start_point > -1)

				var new_path := _walk_grid.get_point_path(
						start_point, end_point)
				result = Array(new_path)
				result.pop_front() # Remove starting cell
				assert(result.size() > 0)

	return result


func _walk_path_point(cell: Vector2) -> int:
	return walk_path_point(_walk_grid, cell)
