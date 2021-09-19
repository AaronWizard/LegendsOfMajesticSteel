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
	var action := _get_best_action(actor, map)
	if action:
		var is_skill := action.skill_index > -1
		var is_move := action.source_cell != actor.origin_cell

		if is_move:
			_queue_move_action(actor, action.source_cell)

		if is_skill:
			_queue_skill_action(actor, action.skill_index, action.target_cell)
		else:
			_queue_wait_action()
	else:
		_queue_wait_action()


func _get_best_action(actor: Actor, map: Map) -> AIScoredAction:
	var walk_actions := []
	var skill_actions := []

	for c in actor.walk_range.get_move_range():
		var cell := c as Vector2
		var walk_action := AIScoredAction.new_move_action(actor, map, cell)
		walk_actions.append(walk_action)

		for i in range(actor.skills.size()):
			var skill_index := i as int
			var skill := actor.skills[skill_index] as Skill
			if skill.energy_cost <= actor.stats.energy:
				var targeting_data := skill.get_targeting_data(
						cell, actor, map)
				for t in targeting_data.valid_targets:
					var target_cell := t as Vector2
					var skill_action := AIScoredAction.new_skill_action(
							actor, map, skill_index, targeting_data,
							target_cell)
					skill_actions.append(skill_action)

	var result: AIScoredAction = null

	if skill_actions.size() > 0:
		skill_actions.sort_custom(self, "_sort_scored_actions")
		result = skill_actions[0] as AIScoredAction
	elif walk_actions.size() > 0:
		walk_actions.sort_custom(self, "_sort_scored_actions")
		result = walk_actions[0] as AIScoredAction

	return result


func _sort_scored_actions(action_a: AIScoredAction, action_b: AIScoredAction) \
		-> bool:
	return action_a.score > action_b.score


func _queue_move_action(actor: Actor, target_cell: Vector2) -> void:
	var path := actor.walk_range.get_walk_path(actor.origin_cell, target_cell)
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
