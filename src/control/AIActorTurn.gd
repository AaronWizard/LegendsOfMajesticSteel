class_name AIActorTurn

enum ActionType { WAIT, MOVE, SKILL }

var _action_queue := []


func get_pauses() -> bool:
	return true


func pick_action(actor: Actor, map: Map) -> Dictionary:
	if _action_queue.empty():
		_queue_actions(actor, map)

	var result := _action_queue.pop_front() as Dictionary
	return result


func _queue_actions(actor: Actor, map: Map) -> void:
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
	var scored_action := scored_actions[0] as AIScoredAction

	var is_skill := scored_action.skill_index > -1
	var is_move := scored_action.source_cell != actor.origin_cell

	if is_move:
		_queue_move_action(actor, scored_action.source_cell)

	if is_skill:
		_queue_skill_action(
				actor, scored_action.skill_index, scored_action.target_cell)
	else:
		_queue_wait_action()


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


func _queue_move_action(actor: Actor, target_cell: Vector2) -> void:
	var path := actor.range_data.get_walk_path(actor.origin_cell, target_cell)
	assert(not path.empty())
	var action := {
		type = ActionType.MOVE,
		path = path
	}
	_action_queue.push_back(action)


func _queue_skill_action(actor: Actor, skill_index: int, target: Vector2) \
		-> void:
	var action := {
		type = ActionType.SKILL,
		skill = actor.skills[skill_index] as Skill,
		target = target
	}
	_action_queue.push_back(action)


func _queue_wait_action() -> void:
	var action := { type = ActionType.WAIT }
	_action_queue.push_back(action)
