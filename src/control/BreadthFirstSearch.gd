class_name BreadthFirstSearch

# Ignores allied actors
static func find_move_range(actor: Actor, map: Map) -> Array:
	var result := [actor.cell]

	var costs := { actor.cell: 0 }

	var queue := [actor.cell]
	while not queue.empty():
		var c = queue.pop_front()
		var current_cell: Vector2 = c
		if costs[current_cell] < actor.stats.move:
			var adjacent := _adjacent_cells(current_cell, actor, map)
			for a in adjacent:
				var adj_cell: Vector2 = a
				if not (adj_cell in result):
					result.append(adj_cell)
					queue.push_back(adj_cell)
					var adj_cost := map.get_cell_move_cost(adj_cell)
					costs[adj_cell] = costs[current_cell] + adj_cost

	return result


static func _adjacent_cells(cell: Vector2, actor: Actor, map: Map) -> Array:
	var result := []

	for d in Directions.ALL_DIRECTIONS:
		var dir: Vector2 = d
		var next_cell := cell + dir
		if map.actor_can_enter_cell(actor, next_cell, true):
			result.append(next_cell)

	return result
