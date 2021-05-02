class_name BreadthFirstSearch

# Ignores allied actors
static func find_move_range(actor: Actor, map: Map) -> Array:
	var result := {}

	var costs := { actor.origin_cell: 0 }
	var queue := [ actor.origin_cell ]

	while not queue.empty():
		var c = queue.pop_front()
		var current_cell := c as Vector2

		if costs[current_cell] <= actor.stats.move:
			result[current_cell] = true

			var adjacent := _adjacent_cells(current_cell, actor, map)
			for a in adjacent:
				var adj_cell := a as Vector2

				if not result.has(adj_cell):
					queue.push_back(adj_cell)

					var adj_cost := map.get_cell_move_cost(adj_cell, actor)
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
