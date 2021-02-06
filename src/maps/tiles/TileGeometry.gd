class_name TileGeometry

static func cells_in_range(source_rect: Rect2, min_dist: int, max_dist: int) \
		-> Array:
	assert(min_dist >= 1)
	assert(max_dist >= min_dist)

	var result := []

	var nw_corner := source_rect.position
	var ne_corner := Vector2(source_rect.end.x - 1, source_rect.position.y)
	var se_corner := source_rect.end - Vector2.ONE
	var sw_corner := Vector2(source_rect.position.x, source_rect.end.y - 1)

	var change: Vector2

	for r in range(min_dist, max_dist + 1):
		var range_index := r as int

		var start: Vector2
		var end: Vector2

		change = Directions.get_direction(Directions.Type.NORTH) * range_index

		# North

		start = nw_corner + change
		end = ne_corner + change
		result += _cells_on_line(start, end, true)

		change = Directions.get_direction(Directions.Type.EAST) * range_index
		# NE quadrant

		start = end
		end = ne_corner + change
		result += _cells_on_line(start, end, false)

		# East

		start = ne_corner + change
		end = se_corner + change
		result += _cells_on_line(start, end, true)

		change = Directions.get_direction(Directions.Type.SOUTH) * range_index
		# SE quadrant

		start = end
		end = se_corner + change
		result += _cells_on_line(start, end, false)

		# South

		start = se_corner + change
		end = sw_corner + change
		result += _cells_on_line(start, end, true)

		change = Directions.get_direction(Directions.Type.WEST) * range_index
		# SW quadrant

		start = end
		end = sw_corner + change
		result += _cells_on_line(start, end, false)

		# West

		start = sw_corner + change
		end = nw_corner + change
		result += _cells_on_line(start, end, true)

		change = Directions.get_direction(Directions.Type.NORTH) * range_index
		# NW quadrant

		start = end
		end = nw_corner + change
		result += _cells_on_line(start, end, false)

	return result


static func _cells_on_line(start: Vector2, end: Vector2, include_ends: bool) \
		-> Array:
	var result := []

	if include_ends:
		result.append(start)

	if end != start:
		var diff := end - start
		diff.x = sign(diff.x)
		diff.y = sign(diff.y)

		var v := Vector2(start + diff)
		while v != end:
			result.append(v)
			v += diff

		if include_ends:
			result.append(end)

	return result
