class_name Pathfinding

# Dijkstra's Algorithm
static func find_move_range(actor: Actor, map: Map) -> Array:
	var result := {}

	var costs := { actor.origin_cell: 0 }
	var queue := [ actor.origin_cell ]

	while not queue.empty():
		var current_cell_index := _next_cell_index(queue, costs)
		var current_cell := queue[current_cell_index] as Vector2
		queue.remove(current_cell_index)

		result[current_cell] = true

		var adjacent := _adjacent_cells(current_cell, actor, map)
		for a in adjacent:
			var adj_cell := a as Vector2
			var adj_cost := map.get_cell_move_cost(adj_cell, actor)
			adj_cost += costs[current_cell] as int

			if adj_cost <= actor.stats.move and ( \
					not costs.has(adj_cell) or (adj_cost < costs[adj_cell]) ):
				costs[adj_cell] = adj_cost
				if queue.find(adj_cell) == -1:
					queue.append(adj_cell)

	return result.keys()


static func _next_cell_index(queue: Array, costs: Dictionary) -> int:
	var result := 0
	var result_cell := queue[result] as Vector2
	var result_cost := costs[result_cell] as int

	for i in range(1, queue.size()):
		var index := i as int
		var other_cell := queue[index] as Vector2
		var other_cost := costs[other_cell] as int

		if other_cost < result_cost:
			result = index
			result_cost = other_cost

	return result


# Ignores allied actors
static func _adjacent_cells(cell: Vector2, actor: Actor, map: Map) -> Array:
	var result := []

	for d in Directions.get_all_vectors():
		var dir := d as Vector2
		var next_cell := cell + dir
		if map.actor_can_enter_cell(actor, next_cell, true):
			result.append(next_cell)

	return result
