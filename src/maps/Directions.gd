class_name Directions

enum Type {
	NORTH,
	SOUTH,
	EAST,
	WEST,
}

const _VALUES := {
	Type.NORTH: Vector2.UP,
	Type.EAST: Vector2.RIGHT,
	Type.SOUTH: Vector2.DOWN,
	Type.WEST: Vector2.LEFT,
}

static func get_all_vectors() -> Array:
	return _VALUES.values()


static func get_vector(direction_type: int) -> Vector2:
	return _VALUES[direction_type]


static func get_closest_direction_type(vector: Vector2) -> int:
	assert(vector != Vector2.ZERO)

	var result: int
	var angle := -1.0

	for dt in _VALUES:
		var direction_type := dt as int
		var direction_vector := _VALUES[direction_type] as Vector2

		if vector == direction_vector:
			result = direction_type
			break
		else:
			var new_angle := abs(vector.angle_to(direction_vector))
			if new_angle == 0:
				result = direction_type
				break
			elif (angle < 0) or (new_angle < angle):
				result = direction_type
				angle = new_angle

	return result


static func left_direction_type(direction_type: int) -> int:
	return _rotated_direction_type(direction_type, PI / 2)


static func right_direction_type(direction_type: int) -> int:
	return _rotated_direction_type(direction_type, PI / -2)


static func _rotated_direction_type(direction_type: int, radians: float) -> int:
	var direction_vector := get_vector(direction_type)
	var rotated_vector := direction_vector.rotated(radians)
	return get_closest_direction_type(rotated_vector)
