class_name TileGeometry


static func manhattan_distance(start: Vector2, end: Vector2) -> int:
	var diff := (end - start).abs()
	return int(diff.x + diff.y)


static func cells_in_range(cell: Vector2, min_dist: int, max_dist: int) \
		-> Array:
	return cells_in_range_rect(cell, 1, min_dist, max_dist)


static func cells_in_range_rect(source_cell: Vector2, source_size: int,
		min_dist: int, max_dist: int, include_diagonals := true) -> Array:
	assert(max_dist >= min_dist)
	assert(max_dist >= 1)
	assert(min_dist >= 0)
	assert(source_size >= 1)

	var result := []

	# Source corners

	var corner_nw := source_cell
	var corner_ne := source_cell + Vector2(source_size - 1, 0)
	var corner_se := source_cell + Vector2(source_size - 1, source_size - 1)
	var corner_sw := source_cell + Vector2(0, source_size - 1)

	assert((source_size > 1) or (
			(corner_nw == corner_ne)
			and (corner_nw == corner_se)
			and (corner_nw == corner_sw)
		))

	# Side quadrants

	var quadrant_n_pos := corner_nw + Vector2(0, -max_dist)
	var quadrant_e_pos := corner_ne + Vector2(max(1, min_dist), 0)
	var quadrant_s_pos := corner_sw + Vector2(0, max(1, min_dist))
	var quadrant_w_pos := corner_nw + Vector2(-max_dist, 0)

	var quadrant_n_size = Vector2(source_size, max_dist - max(min_dist, 1) + 1)
	var quadrant_e_size = Vector2(max_dist - max(min_dist, 1) + 1, source_size)
	var quadrant_s_size = Vector2(source_size, max_dist - max(min_dist, 1) + 1)
	var quadrant_w_size = Vector2(max_dist - max(min_dist, 1) + 1, source_size)

	var quadrant_rect_n := Rect2(quadrant_n_pos, quadrant_n_size)
	var quadrant_rect_e := Rect2(quadrant_e_pos, quadrant_e_size)
	var quadrant_rect_s := Rect2(quadrant_s_pos, quadrant_s_size)
	var quadrant_rect_w := Rect2(quadrant_w_pos, quadrant_w_size)

	if min_dist == 0:
		var self_rect := Rect2(
			source_cell, Vector2(source_size, source_size))
		result.append_array(get_rect_cells(self_rect))

	result.append_array(get_rect_cells(quadrant_rect_n))
	result.append_array(get_rect_cells(quadrant_rect_e))
	result.append_array(get_rect_cells(quadrant_rect_s))
	result.append_array(get_rect_cells(quadrant_rect_w))

	if include_diagonals and (max_dist > 1):
		var quadrant_nw_pos := corner_nw + Vector2(-max_dist, -max_dist)
		var quadrant_ne_pos := corner_ne + Vector2(1, -max_dist)
		var quadrant_se_pos := corner_se + Vector2(1, 1)
		var quadrant_sw_pos := corner_sw + Vector2(-max_dist, 1)

		var quadrant_rect_nw := Rect2(
				quadrant_nw_pos, Vector2(max_dist, max_dist))
		var quadrant_rect_ne := Rect2(
				quadrant_ne_pos, Vector2(max_dist, max_dist))
		var quadrant_rect_se := Rect2(
				quadrant_se_pos, Vector2(max_dist, max_dist))
		var quadrant_rect_sw := Rect2(
				quadrant_sw_pos, Vector2(max_dist, max_dist))

		var flood_start_nw := corner_nw + Vector2(-1, -1)
		var flood_start_ne := corner_ne + Vector2(1, -1)
		var flood_start_se := corner_se + Vector2(1, 1)
		var flood_start_sw := corner_sw + Vector2(-1, 1)

		result.append_array(_flood_fill(corner_nw, flood_start_nw, min_dist,
				max_dist, quadrant_rect_nw))
		result.append_array(_flood_fill(corner_ne, flood_start_ne, min_dist,
				max_dist, quadrant_rect_ne))
		result.append_array(_flood_fill(corner_se, flood_start_se, min_dist,
				max_dist, quadrant_rect_se))
		result.append_array(_flood_fill(corner_sw, flood_start_sw, min_dist,
				max_dist, quadrant_rect_sw))

	return result


static func get_line(start: Vector2, end: Vector2, include_ends := true) \
		-> Array:
	var result := []
	if start == end:
		result.append(start)
	else:
		var line_size := _get_diagonal_distance(end, start) as float
		for i in range(line_size + 1):
			var weight := i / line_size
			var x = lerp(start.x, end.x, weight)
			var y = lerp(start.y, end.y, weight)
			var cell := Vector2(x, y).round()
			assert(result.find(cell) == -1)
			result.append(cell)

	if not include_ends:
		result.pop_front()
		result.pop_back()

	return result


static func get_thick_line(start: Vector2, end: Vector2, size: int) \
		-> Array:
	var result: Array
	var start_cells := get_rect_cells(Rect2(start, Vector2(size, size)))

	if start == end:
		result = start_cells
	else:
		var end_cells := get_rect_cells(Rect2(end, Vector2(size, size)))
		assert(start_cells.size() == end_cells.size())

		var all_cells := {}
		for i in range(start_cells.size()):
			var inner_start := start_cells[i] as Vector2
			var inner_end := end_cells[i] as Vector2
			var line := get_line(inner_start, inner_end)
			for c in line:
				all_cells[c] = true
		result = all_cells.keys()

	return result


static func get_rect_cells(rect: Rect2) -> Array:
	var result := []
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			var covered := rect.position + Vector2(x, y)
			result.append(covered)
	return result


static func get_rect_side_cells(rect: Rect2, direction: int, distance: int) \
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

	start += Directions.get_vector(direction) * distance
	end += Directions.get_vector(direction) * distance

	return get_line(start, end)


static func get_closest_rect_cell(cell: Vector2, rect: Rect2) -> Vector2:
	var result: Vector2
	var dist_sqr := -1.0

	for rc in get_rect_cells(rect):
		var rect_cell := rc as Vector2
		var new_dist_sqr := cell.distance_squared_to(rect_cell)
		if (dist_sqr < 0) or (new_dist_sqr < dist_sqr):
			result = rect_cell
			dist_sqr = new_dist_sqr

			if dist_sqr == 0:
				break

	return result


static func direction_from_rect_to_cell(cell: Vector2, rect: Rect2) -> int:
	var rect_cell := get_closest_rect_cell(cell, rect)
	return Directions.get_closest_direction_type(cell - rect_cell)


static func center_cell_of_cells(cells: Array) -> Vector2:
	var started := false
	var rect := Rect2()
	for c in cells:
		var cell := c as Vector2
		if started:
			rect.position.x = min(rect.position.x, cell.x)
			rect.position.y = min(rect.position.y, cell.y)
			rect.end.x = max(rect.end.x, cell.x)
			rect.end.y = max(rect.end.y, cell.y)
		else:
			rect.position = cell
			rect.end = cell

	var result := rect.position + (rect.size / 2.0)
	return result


static func _flood_fill(origin: Vector2, start: Vector2,
		min_dist: int, max_dist: int, bounds: Rect2) -> Array:
	var result := {}

	var stack := [start]
	var visited := {}

	while not stack.empty():
		var current := stack.pop_back() as Vector2

		if not visited.has(current) and bounds.has_point(current) \
				and (manhattan_distance(origin, current) <= max_dist):
			visited[current] = true
			if manhattan_distance(origin, current) >= min_dist:
				result[current] = true

			for d in Directions.get_all_vectors():
				var dir := d as Vector2
				var adj := current + dir

				if not visited.has(adj):
					stack.push_back(adj)

	return result.keys()


static func _get_diagonal_distance(start: Vector2, end: Vector2) -> int:
	var diff := (end - start).abs()
	return int(max(diff.x, diff.y))
