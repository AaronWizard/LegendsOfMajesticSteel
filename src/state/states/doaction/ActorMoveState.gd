class_name ActorMoveState
extends ActorActionState

var _path: Array


func unhandled_input(event: InputEvent) -> void:
	var is_player := _game.current_actor.faction == int(Actor.Faction.PLAYER)
	var is_mouse := event is InputEventMouseButton

	if is_player and is_mouse \
			and (event.button_index == BUTTON_LEFT) \
			and _game.map.actor_can_enter_cell(
					_game.current_actor, _game.current_actor.origin_cell):
		_path.clear()


func start(data: Dictionary) -> void:
	_path = data.path as Array
	assert(_path)
	assert(_path.size() > 0)
	assert(_path[0] is Vector2)

	_game.interface.camera.follow_actor(_game.current_actor)
	_game.interface.mouse.dragging_enabled = false
	_game.interface.map_highlights.moves_visible = true

	.start(data)


func _ends_turn() -> bool:
	return false


func _run() -> void:
	while _path.size() > 0:
		var cell := _path.pop_front() as Vector2
		yield(_game.current_actor.move_step(cell), "completed")
