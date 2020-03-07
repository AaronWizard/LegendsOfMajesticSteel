class_name TileGeometry

static func cells_in_range(source: Vector2, min_dist: int, max_dist: int) \
		-> Array:
	var result := []

	for i in range(min_dist, max_dist + 1):
		result.append(Vector2(0, -i) + source) # North
		result.append(Vector2(i, 0) + source) # East
		result.append(Vector2(0, i) + source) # South
		result.append(Vector2(-i, 0) + source) # West

		for j in range(1, i):
			result.append(Vector2(j, j - i) + source) # NE quadrant
			result.append(Vector2(j, i - j) + source) # SE quadrant
			result.append(Vector2(-j, i - j) + source) # SW quadrant
			result.append(Vector2(-j, j - i) + source) # NW quadrant

	return result
