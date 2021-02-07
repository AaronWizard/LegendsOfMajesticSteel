class_name TileGeometry

static func cells_in_range(cell: Vector2, min_dist: int, max_dist: int) \
		-> Array:
	return cells_in_range_rect(Rect2(cell, Vector2.ONE), min_dist, max_dist)


static func cells_in_range_rect(source_rect: Rect2,
		min_dist: int, max_dist: int) -> Array:
	assert(max_dist >= min_dist)

	var result := []

	var start := min_dist
	if start < 1:
		start = 1
		var rect_cells := get_rect_cells(source_rect)
		result.append_array(rect_cells)

	for r in range(min_dist, max_dist + 1):
		var range_index := r as int

		var north_side := _rect_side(
				source_rect, Directions.Type.NORTH, range_index)
		var east_side := _rect_side(
				source_rect, Directions.Type.EAST, range_index)
		var south_side := _rect_side(
				source_rect, Directions.Type.SOUTH, range_index)
		var west_side := _rect_side(
				source_rect, Directions.Type.WEST, range_index)

		var ne_side := get_line(north_side.back() as Vector2, \
				east_side.front() as Vector2, false)
		var se_side := get_line(east_side.back() as Vector2, \
				south_side.front() as Vector2, false)
		var sw_side := get_line(south_side.back() as Vector2, \
				west_side.front() as Vector2, false)
		var nw_side := get_line(west_side.back() as Vector2, \
				north_side.front() as Vector2, false)

		result.append_array(north_side)
		result.append_array(ne_side)
		result.append_array(east_side)
		result.append_array(se_side)
		result.append_array(south_side)
		result.append_array(sw_side)
		result.append_array(west_side)
		result.append_array(nw_side)

	return result


static func get_line(start: Vector2, end: Vector2, include_ends := true) \
		-> Array:
	var result := []
	if start == end:
		result.append(start)
	else:
		var line_size := get_diagonal_distance(end, start) as float
		for i in range(line_size + 1):
			var weight := i / line_size
			var x = lerp(start.x, end.x, weight)
			var y = lerp(start.y, end.y, weight)
			var cell := Vector2(x, y).round()
			result.append(cell)

	if not include_ends:
		result.pop_front()
		result.pop_back()

	return result


static func get_diagonal_distance(start: Vector2, end: Vector2) -> int:
	var dx := end.x - start.x
	var dy := end.y - start.y

	dx = abs(dx)
	dy = abs(dy)

	return int(max(dx, dy))


static func get_rect_cells(rect: Rect2) -> Array:
	var result := []
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			var covered := Vector2(x, y)
			result.append(covered)
	return result


static func _rect_side(rect: Rect2, direction: int, distance: int) \
		-> Array:
	var nw_corner := rect.position
	var ne_corner := Vector2(rect.end.x - 1, rect.position.y)
	var se_corner := rect.end - Vector2.ONE
	var sw_corner := Vector2(rect.position.x, rect.end.y - 1)

	var start: Vector2
	var end: Vector2

	match direction:
		Directions.Type.NORTH:
			start = nw_corner
			end = ne_corner
		Directions.Type.EAST:
			start = ne_corner
			end = se_corner
		Directions.Type.SOUTH:
			start = se_corner
			end = sw_corner
		Directions.Type.WEST:
			start = sw_corner
			end = nw_corner
		_:
			assert(false, "Invalid direction %d" % direction)

	start += Directions.get_direction(direction) * distance
	end += Directions.get_direction(direction) * distance

	return get_line(start, end)
