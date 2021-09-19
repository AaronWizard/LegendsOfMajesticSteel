class_name WalkRangeFactory


static func create_walk_range(actor: Actor, map: Map) -> WalkRange:
	var origin_cell := actor.origin_cell

	var base_move_range := _create_base_move_range(actor, map)
	var true_move_range := _create_true_move_range(base_move_range, actor, map)
	var visible_move_range := _create_visible_move_range(true_move_range,
			base_move_range, actor)

	var walk_grid := _create_walk_grid(base_move_range)

	var result := WalkRange.new(
			origin_cell, true_move_range, visible_move_range, walk_grid)
	
	return result


# Includes cells with allies on them. Actor can pass through allies but not end
# their movement on an occupied cell.
static func _create_base_move_range(actor: Actor, map: Map) -> Dictionary:
	var result := {}

	var mr := Pathfinding.find_move_range(actor, map)
	for c in mr:
		var cell := c as Vector2
		result[cell] = true

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


# Includes cells outside the actor's true move range but would be covered by
# the actor if it's a multi-tile actor. Visible cells are keys and their
# corresponding origin cells are the values.
static func _create_visible_move_range(true_move_range: Dictionary,
		base_move_range: Dictionary, actor: Actor) -> Dictionary:
	var result := {}

	for oc in base_move_range:
		var origin_cell := oc as Vector2
		_add_visible_cells_to_move_range(result, origin_cell, actor)
	# Override assignments from base_move_range
	for oc in true_move_range:
		var origin_cell := oc as Vector2
		_add_visible_cells_to_move_range(result, origin_cell, actor)

	return result


static func _add_visible_cells_to_move_range(visible_move_range: Dictionary,
		origin_cell: Vector2,  actor: Actor) -> void:
	var covered := actor.get_covered_cells_at_cell(origin_cell)
	for cc in covered:
		var covered_cell := cc as Vector2
		visible_move_range[covered_cell] = origin_cell


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
		for d in Directions.get_all_vectors():
			var dir := d as Vector2
			var adj_cell := dir + cell

			var adj_point := WalkRange.walk_path_point(walk_grid, adj_cell)
			if (adj_point > -1) \
					and not walk_grid.are_points_connected(point, adj_point):
				walk_grid.connect_points(point, adj_point)
