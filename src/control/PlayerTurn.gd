class_name PlayerTurn
extends TurnController


signal _input_processed(actor)


func pick_actor(actors: Array, control: BattleControl) -> void:
	_set_actor_cursors(actors, true)

	var camera_position := _average_position(actors)
	control.camera.move_to_position(camera_position)

	control.mouse.dragging_enabled = true

	var actor: Actor = yield(self, '_input_processed')

	_set_actor_cursors(actors, false)

	emit_signal("actor_picked", actor)


func _set_actor_cursors(actors: Array, cursor_visible: bool) -> void:
	for a in actors:
		var actor := a as Actor
		actor.target_visible = cursor_visible


func _average_position(actors: Array) -> Vector2:
	var result := Vector2.ZERO

	for a in actors:
		var actor := a as Actor
		result += actor.position

	result /= actors.size()

	return result
