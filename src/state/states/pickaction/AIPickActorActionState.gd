class_name AIPickActorActionState
extends PickActorActionState

var _actor_ai := AIActorTurn.new()


func start(_data: Dictionary) -> void:
	call_deferred("_pick_action")


func _pick_action() -> void:
	var action := _actor_ai.pick_action(_game.current_actor, _game.map)
	match (action.type as int):
		AIActorTurn.ActionType.MOVE:
			_do_move(action.path as Array)
		AIActorTurn.ActionType.SKILL:
			_do_skill(action.skill as Skill, action.target as Vector2)
		_:
			assert(action.type == AIActorTurn.ActionType.WAIT)
			_do_wait()
