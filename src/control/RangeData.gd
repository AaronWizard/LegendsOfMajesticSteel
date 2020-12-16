class_name RangeData

var _base_move_range: Dictionary
var _true_move_range: Dictionary
var _walk_grid: AStar2D
var _targeting_data_set: Dictionary
var _valid_source_cells: Dictionary


static func walk_path_point(walk_grid: AStar2D, cell: Vector2) -> int:
	var result := walk_grid.get_closest_point(cell)
	if (result == -1) or (walk_grid.get_point_position(result) != cell):
		result = -1
	return result


func get_visible_move_range() -> Array:
	return _base_move_range.keys()


func get_move_range() -> Array:
	return _true_move_range.keys()


func can_move_to_cell(cell: Vector2) -> bool:
	return _true_move_range.has(cell)


func get_walk_path(start: Vector2, end: Vector2) -> Array:
	var result := []

	if (start != end) and _true_move_range.has(start) \
			and _true_move_range.has(end):
		var end_point := _walk_path_point(end)
		if end_point > -1:
			var start_point := _walk_path_point(start)
			assert(start_point > -1)

			result = _walk_grid.get_point_path(start_point, end_point)
			result.pop_front() # Remove starting cell
		assert(result.size() > 0)

	return result


func get_targeting_data(cell: Vector2, skill_index: int) -> TargetingData:
	var key := Vector3(cell.x, cell.y, skill_index)
	var result := _targeting_data_set[key] as TargetingData
	return result


func get_valid_skill_indices_at_cell(cell: Vector2) -> Array:
	var result := []

	if _valid_source_cells.has(cell):
		var skills_set := _valid_source_cells[cell] as Dictionary
		result = skills_set.keys()

	return result


func skill_is_valid_at_cell(cell: Vector2, skill_index: int) -> bool:
	var result := false
	if _valid_source_cells.has(cell):
		var skills_set := _valid_source_cells[cell] as Dictionary
		result = skills_set.has(skill_index)
	return result


func get_valid_skill_source_cells() -> Array:
	return _valid_source_cells.keys()


func _walk_path_point(cell: Vector2) -> int:
	return walk_path_point(_walk_grid, cell)
