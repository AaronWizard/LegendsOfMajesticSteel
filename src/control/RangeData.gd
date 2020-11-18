class_name RangeData

var visible_move_range := {} # Set; keys are cells
var move_range := {} # Set; keys are cells

# Keys are cells
# Values are dictionaries
#		keys are indicies to actor ability, values are TargetingData
var valid_ability_sources := {}

var _walk_grid := AStar2D.new()


func _init(actor: Actor, map: Map) -> void:
	_init_visible_move_range(actor, map)
	_init_move_range(actor, map)
	_init_walk_grid_paths()
	_init_valid_ability_sources(actor, map)


func get_walk_path(start: Vector2, end: Vector2) -> Array:
	var result := []

	if (start != end) and move_range.has(start) and move_range.has(end):
		var end_point := _walk_path_point(end)
		if end_point > -1:
			var start_point := _walk_path_point(start)
			assert(start_point > -1)

			result = _walk_grid.get_point_path(start_point, end_point)
			result.pop_front() # Remove starting cell
		assert(result.size() > 0)

	return result


func _init_visible_move_range(actor: Actor, map: Map) -> void:
	var mr := BreadthFirstSearch.find_move_range(actor, map)
	for c in mr:
		var cell := c as Vector2
		visible_move_range[cell] = true


func _init_move_range(actor: Actor, map: Map) -> void:
	for c in visible_move_range:
		var cell: Vector2 = c

		_walk_grid.add_point(
			_walk_grid.get_available_point_id(),
			cell
		)

		if map.actor_can_enter_cell(actor, cell):
			move_range[cell] = true


func _init_walk_grid_paths() -> void:
	for p in _walk_grid.get_points():
		var point: int = p
		var cell := _walk_grid.get_point_position(point)
		for d in Directions.ALL_DIRECTIONS:
			var dir: Vector2 = d
			var adj_cell := dir + cell

			var adj_point := _walk_path_point(adj_cell)
			if (adj_point > -1) \
					and not _walk_grid.are_points_connected(point, adj_point):
				_walk_grid.connect_points(point, adj_point)


func _walk_path_point(cell: Vector2) -> int:
	var result := _walk_grid.get_closest_point(cell)
	if (result == -1) or (_walk_grid.get_point_position(result) != cell):
		result = -1
	return result


func _init_valid_ability_sources(actor: Actor, map: Map) -> void:
	for sc in move_range.keys():
		var source_cell := sc as Vector2
		for i in range(actor.stats.abilities.size()):
			var index := i as int
			var ability := actor.stats.abilities[index] as Ability
			var targeting_data := ability.get_targeting_data(source_cell, actor, map)
			assert(targeting_data.source_cell == source_cell)
			if not targeting_data.valid_targets.empty():
				_set_valid_ability_source(targeting_data, index)

func _set_valid_ability_source(targeting_data: Ability.TargetingData,
		ability_index: int) -> void:
	if not valid_ability_sources.has(targeting_data.source_cell):
		valid_ability_sources[targeting_data.source_cell] = {}
	var data := valid_ability_sources[targeting_data.source_cell] as Dictionary

	assert(not data.has(ability_index))
	data[ability_index] = targeting_data
