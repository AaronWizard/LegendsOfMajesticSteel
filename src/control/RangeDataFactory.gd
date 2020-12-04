class_name RangeDataFactory


static func create_range_data(actor: Actor, map: Map) -> RangeData:
	var base_move_range := _create_base_move_range(actor, map)
	var true_move_range := _create_true_move_range(base_move_range, actor, map)
	var walk_grid := _create_walk_grid(base_move_range)
	var targeting_data_set := _create_targeting_data_set(
			true_move_range, actor, map)
	var valid_source_cells := _create_valid_source_cells(targeting_data_set)

	var result := RangeData.new()
	result._base_move_range = base_move_range
	result._true_move_range = true_move_range
	result._walk_grid = walk_grid
	result._targeting_data_set = targeting_data_set
	result._valid_source_cells = valid_source_cells

	return result


# Includes cells with allies on them. Actor can pass through allies but not end
# their movement on an occupied cell.
static func _create_base_move_range(actor: Actor, map: Map) -> Dictionary:
	var result := {}

	var mr := BreadthFirstSearch.find_move_range(actor, map)
	for c in mr:
		var cell := c as Vector2
		result[cell] = true

	return result


# Cells the actor can actually occupy
static func _create_true_move_range(base_move_range: Dictionary,
		actor: Actor, map: Map) -> Dictionary:
	var result := {}

	for c in base_move_range:
		var cell: Vector2 = c
		if map.actor_can_enter_cell(actor, cell):
			result[cell] = true

	return result


static func _create_walk_grid(move_range: Dictionary) -> AStar2D:
	var result := AStar2D.new()

	for c in move_range:
		var cell: Vector2 = c
		result.add_point(result.get_available_point_id(), cell)
	_init_walk_grid_paths(result)

	return result


static func _init_walk_grid_paths(walk_grid: AStar2D) -> void:
	for p in walk_grid.get_points():
		var point: int = p
		var cell := walk_grid.get_point_position(point)
		for d in Directions.ALL_DIRECTIONS:
			var dir: Vector2 = d
			var adj_cell := dir + cell

			var adj_point := RangeData.walk_path_point(walk_grid, adj_cell)
			if (adj_point > -1) \
					and not walk_grid.are_points_connected(point, adj_point):
				walk_grid.connect_points(point, adj_point)


# Keys are Vector3s. (key.x, key.y) is the source cell, key.z is the ability
# index.
# Values are TargetingData
static func _create_targeting_data_set(move_range: Dictionary,
		actor: Actor, map: Map) -> Dictionary:
	var result := {}

	for sc in move_range.keys():
		var source_cell := sc as Vector2
		for i in range(actor.stats.abilities.size()):
			var ability_index := i as int
			var ability := actor.stats.abilities[ability_index] as Ability
			var targeting_data := ability.get_targeting_data(
					source_cell, actor, map)

			var key = Vector3(source_cell.x, source_cell.y, ability_index)
			result[key] = targeting_data

	return result


# Keys are Vector2s. Values are dictionaries of ints (used as a set).
static func _create_valid_source_cells(targeting_data_set: Dictionary) \
		-> Dictionary:
	var result := {}

	for k in targeting_data_set:
		var key := k as Vector3
		var cell := Vector2(key.x, key.y)
		var ability_index := int(key.z)
		var targeting_data := targeting_data_set[key] as TargetingData

		if not targeting_data.valid_targets.empty():
			if not result.has(cell):
				result[cell] = {}
			(result[cell] as Dictionary)[ability_index] = true

	return result
