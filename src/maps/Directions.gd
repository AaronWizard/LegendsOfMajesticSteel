class_name Directions

enum {
	NORTH,
	SOUTH,
	EAST,
	WEST,
}

const _VALUES := {
	NORTH: Vector2(0, -1),
	EAST: Vector2(1, 0),
	SOUTH: Vector2(0, 1),
	WEST: Vector2(-1, 0),
}

static func get_all_directions() -> Array:
	return _VALUES.values()
