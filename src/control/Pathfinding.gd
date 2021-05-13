class_name Pathfinding

# Ignores allied actors
static func find_move_range(actor: Actor, map: Map) -> Array:
	var result := {}

	var costs := { actor.origin_cell: 0 }
	var queue := [ actor.origin_cell ]

	while not queue.empty():
		var c = queue.pop_front()
		var current_cell := c as Vector2

		result[current_cell] = true

		var adjacent := _adjacent_cells(current_cell, actor, map)
		for a in adjacent:
			var adj_cell := a as Vector2
			var adj_cost := map.get_cell_move_cost(adj_cell, actor)
			adj_cost += costs[current_cell] as int

			if adj_cost <= actor.stats.move \
					and (not result.has(adj_cell) or (adj_cost < costs[adj_cell])):
				queue.push_back(adj_cell)
				costs[adj_cell] = costs[current_cell] + adj_cost

	return result.keys()


static func _adjacent_cells(cell: Vector2, actor: Actor, map: Map) -> Array:
	var result := []

	for d in Directions.get_all_vectors():
		var dir := d as Vector2
		var next_cell := cell + dir
		if map.actor_can_enter_cell(actor, next_cell, true):
			result.append(next_cell)

	return result
