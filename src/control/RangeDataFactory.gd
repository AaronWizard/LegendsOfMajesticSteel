class_name RangeDataFactory


static func create_range_data(actor: Actor, map: Map) -> RangeData:
	var base_move_range := _create_base_move_range(actor, map)
	var visible_move_range := _create_visible_move_range(base_move_range, actor)
	var true_move_range := _create_true_move_range(base_move_range, actor, map)

	var walk_grid := _create_walk_grid(base_move_range)

	var targeting_data_set := _create_targeting_data_set(
			true_move_range, actor, map)
	var valid_source_cells := _create_valid_source_cells(targeting_data_set)

	var result := RangeData.new()
	result._visible_move_range = visible_move_range
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


# Includes cells outside the actor's true move range but would be covered by
# the actor if it's a multi-tile actor. Visible cells are keys and their
# corresponding origin cells are the values.
static func _create_visible_move_range(base_move_range: Dictionary,
		actor: Actor) -> Dictionary:
	var result := {}

	for oc in base_move_range:
		var origin_cell := oc as Vector2
		result[origin_cell] = origin_cell

		var covered := actor.get_covered_cells_at_cell(origin_cell)
		for cc in covered:
			var covered_cell := cc as Vector2
			if not result.has(covered_cell):
				result[covered_cell] = origin_cell

	return result


# Cells the actor can actually occupy
static func _create_true_move_range(base_move_range: Dictionary,
		actor: Actor, map: Map) -> Dictionary:
	var result := {}

	for c in base_move_range:
		var cell := c as Vector2
		if map.actor_can_enter_cell(actor, cell):
			result[cell] = true

	return result


static func _create_walk_grid(move_range: Dictionary) -> AStar2D:
	var result := AStar2D.new()

	for c in move_range:
		var cell := c as Vector2
		result.add_point(result.get_available_point_id(), cell)
	_init_walk_grid_paths(result)

	return result


static func _init_walk_grid_paths(walk_grid: AStar2D) -> void:
	for p in walk_grid.get_points():
		var point := p as int
		var cell := walk_grid.get_point_position(point)
		for d in Directions.get_all_directions():
			var dir := d as Vector2
			var adj_cell := dir + cell

			var adj_point := RangeData.walk_path_point(walk_grid, adj_cell)
			if (adj_point > -1) \
					and not walk_grid.are_points_connected(point, adj_point):
				walk_grid.connect_points(point, adj_point)


# Keys are Vector3s. (key.x, key.y) is the source cell, key.z is the skill
# index.
# Values are TargetingData
static func _create_targeting_data_set(move_range: Dictionary,
		actor: Actor, map: Map) -> Dictionary:
	var result := {}

	for sc in move_range.keys():
		var source_cell := sc as Vector2
		for i in range(actor.stats.skills.size()):
			var skill_index := i as int
			var skill := actor.stats.skills[skill_index] as Skill
			var targeting_data := skill.get_targeting_data(
					source_cell, actor, map)

			var key := Vector3(source_cell.x, source_cell.y, skill_index)
			result[key] = targeting_data

	return result


# Keys are Vector2s. Values are dictionaries of ints (used as a set).
static func _create_valid_source_cells(targeting_data_set: Dictionary) \
		-> Dictionary:
	var result := {}

	for k in targeting_data_set:
		var key := k as Vector3
		var cell := Vector2(key.x, key.y)
		var skill_index := int(key.z)
		var targeting_data := targeting_data_set[key] as TargetingData

		if not targeting_data.valid_targets.empty():
			if not result.has(cell):
				result[cell] = {}
			(result[cell] as Dictionary)[skill_index] = true

	return result
