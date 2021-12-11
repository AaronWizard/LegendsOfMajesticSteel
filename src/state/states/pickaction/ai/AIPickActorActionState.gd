class_name AIPickActorActionState
extends PickActorActionState


func start(_data: Dictionary) -> void:
	call_deferred("_pick_action")


func _pick_action() -> void:
	var action := _game.actor_ai.pick_action(
			_game.current_actor, _game.map, _game.get_current_walk_range())
	match (action.type as int):
		AIActorTurn.ActionType.MOVE:
			_do_move(action.path as Array)
		AIActorTurn.ActionType.SKILL:
			_do_skill(action.skill as Skill, action.target as Vector2)
		_:
			assert(action.type == AIActorTurn.ActionType.WAIT)
			_do_wait()
