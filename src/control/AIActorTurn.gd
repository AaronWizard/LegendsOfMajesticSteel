class_name AIActorTurn

enum ActionType { WAIT, MOVE, SKILL }

var _next_skill_index := -1
var _next_target: Vector2


func get_pauses() -> bool:
	return true


func pick_action(actor: Actor, map: Map) -> Dictionary:
	var result: Dictionary

	if _next_skill_index > -1:
		result = _skill_action(actor)
	else:
		result = _choose_next_action(actor, map)

	return result


func _choose_next_action(actor: Actor, map: Map) -> Dictionary:
	var result := _wait_action()

	var range_data := actor.range_data
	var scored_actions := []

	if range_data.get_valid_skill_source_cells().empty():
		for c in range_data.get_move_range():
			var source_cell := c as Vector2
			var action := _get_scored_move_action(actor, map, source_cell)
			scored_actions.append(action)
	else:
		for c in range_data.get_valid_skill_source_cells():
			var source_cell := c as Vector2
			var actions := _get_scored_skill_actions(actor, map, source_cell)
			scored_actions.append_array(actions)

	scored_actions.sort_custom(self, "_sort_scored_actions")
	var action := scored_actions[0] as AIScoredAction

	var is_skill := action.skill_index > -1
	var is_move := action.source_cell != actor.origin_cell

	if is_move:
		result = _move_action(actor, action.source_cell)

	if is_skill:
		_next_skill_index = action.skill_index
		_next_target = action.target_cell
		if not is_move:
			result = _skill_action(actor)

	return result


func _get_scored_move_action(actor: Actor, map: Map, source_cell: Vector2) \
		-> AIScoredAction:
	assert(actor.range_data.get_valid_skill_indices_at_cell(
			source_cell).empty())
	var result := AIScoredAction.new_move_action(actor, map, source_cell)
	return result


func _get_scored_skill_actions(actor: Actor, map: Map, source_cell: Vector2) \
		-> Array:
	var result := []

	var skill_is := actor.range_data.get_valid_skill_indices_at_cell(
			source_cell)
	assert(not skill_is.empty())

	for i in skill_is:
		var skill_index := i as int
		var targeting_data := actor.range_data.get_targeting_data(
				source_cell, skill_index)
		assert(not targeting_data.valid_targets.empty())
		for t in targeting_data.valid_targets:
			var target_cell := t as Vector2
			var scored_action := AIScoredAction.new_skill_action(
					actor, map, skill_index, targeting_data,
					target_cell)
			result.append(scored_action)

	return result


func _sort_scored_actions(action_a: AIScoredAction, action_b: AIScoredAction) \
		-> bool:
	return action_a.score > action_b.score


func _move_action(actor: Actor, target_cell: Vector2) -> Dictionary:
	var path := actor.range_data.get_walk_path(actor.origin_cell, target_cell)
	assert(not path.empty())
	return {
		type = ActionType.MOVE,
		path = path
	}


func _skill_action(actor: Actor) -> Dictionary:
	var skill := actor.skills[_next_skill_index] as Skill
	_next_skill_index = -1

	return {
		type = ActionType.SKILL,
		skill = skill,
		target = _next_target
	}


func _wait_action() -> Dictionary:
	return { type = ActionType.WAIT }
