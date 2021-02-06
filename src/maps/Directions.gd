class_name Directions

enum Type {
	NORTH,
	SOUTH,
	EAST,
	WEST,
}

const _VALUES := {
	Type.NORTH: Vector2(0, -1),
	Type.EAST: Vector2(1, 0),
	Type.SOUTH: Vector2(0, 1),
	Type.WEST: Vector2(-1, 0),
}

static func get_all_directions() -> Array:
	return _VALUES.values()


static func get_direction(direction: int) -> Vector2:
	return _VALUES[direction]
