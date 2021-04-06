class_name AIActorTurn

enum ActionType { WAIT, MOVE, SKILL }

var _random := ExtRandomNumberGenerator.new()

var _moved := false


func _ready() -> void:
	_random.randomize()
	_moved = false


func get_pauses() -> bool:
	return true


func pick_action(actor: Actor, _map: Map) -> Dictionary:
	var result := _wait_action()

	var range_data := actor.range_data
	if not range_data.get_valid_skill_source_cells().empty():
		_moved = false

		if not range_data.get_valid_skill_indices_at_cell(
				actor.origin_cell).empty():
			result = _pick_random_skill(actor, range_data)
		else:
			var path := _pick_random_action_path(actor.origin_cell, range_data)
			result = _move_action(path)
	else:
		var want_move := not _moved
		_moved = want_move

		if want_move:
			var path := _pick_random_path(actor.origin_cell, range_data)
			result = _move_action(path)

	return result


func _pick_random_path(start_cell: Vector2, range_data: RangeData) -> Array:
	var cells := range_data.get_move_range()
	cells.erase(start_cell)
	assert(not (start_cell in cells))

	return _random_path(start_cell, range_data, cells)


func _pick_random_action_path(start_cell: Vector2, range_data: RangeData) \
		-> Array:
	var cells := range_data.get_valid_skill_source_cells()
	return _random_path(start_cell, range_data, cells)


func _random_path(start_cell: Vector2, range_data: RangeData, cells: Array) \
		-> Array:
	var target := _random.rand_array_element(cells) as Vector2

	var path = range_data.get_walk_path(start_cell, target)
	assert(path.size() > 0)

	return path


func _pick_random_skill(actor: Actor, range_data: RangeData) -> Dictionary:
	var skill_indicies := range_data.get_valid_skill_indices_at_cell(
			actor.origin_cell)
	var skill_index = _random.rand_array_element(skill_indicies) as int

	var skill := actor.skills[skill_index] as Skill
	var targeting_data := \
			range_data.get_targeting_data(actor.origin_cell, skill_index)

	# Pick random target
	var target_cell := \
			_random.rand_array_element(targeting_data.valid_targets) as Vector2

	var result := _skill_action(skill, target_cell)

	return result


func _move_action(path: Array) -> Dictionary:
	return {
		type = ActionType.MOVE,
		path = path
	}


func _skill_action(skill: Skill, target: Vector2) -> Dictionary:
	return {
		type = ActionType.SKILL,
		skill = skill,
		target = target
	}


func _wait_action() -> Dictionary:
	return { type = ActionType.WAIT }
