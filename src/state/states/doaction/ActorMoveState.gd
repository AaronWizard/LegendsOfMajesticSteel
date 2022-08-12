class_name ActorMoveState
extends ActorActionState

var _path: Array
var _can_cancel: bool

func unhandled_input(event: InputEvent) -> void:
	var is_player := _game.current_actor.faction == int(Actor.Faction.PLAYER)
	var is_mouse := event is InputEventMouseButton

	if is_player and is_mouse and (event.button_index == BUTTON_LEFT) \
			and _can_cancel:
		_path.clear()


func start(data: Dictionary) -> void:
	_path = data.path as Array
	assert(_path)
	assert(_path.size() > 0)
	assert(_path[0] is Vector2)

	_game.interface.camera.follow_actor(_game.current_actor)

	.start(data)


func _ends_turn() -> bool:
	return false


func _run() -> void:
	var first_cell := _game.current_actor.origin_cell
	_game.current_actor.report_moves = false

	while _path.size() > 0:
		var cell := _path.pop_front() as Vector2
		_can_cancel = _game.map.actor_can_enter_cell(_game.current_actor, cell)
		yield(_game.current_actor.move_step(cell), "completed")

	_game.current_actor.report_moves = true
	if first_cell != _game.current_actor.origin_cell:
		_game.current_actor.emit_signal("moved")
