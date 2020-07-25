class_name PlayerTurn
extends TurnController


signal _input_processed(actor)

var _control: BattleControl = null
var _actors := []

func pick_actor(actors: Array, control: BattleControl) -> void:
	_set_actor_cursors(actors, true)

	var camera_position := _average_position(actors)
	control.camera.move_to_position(camera_position)

	control.mouse.dragging_enabled = true

	# warning-ignore:return_value_discarded
	control.mouse.connect("click", self, "_on_mouse_click")

	_control = control
	_actors = actors

	var actor: Actor = yield(self, '_input_processed')

	control.mouse.disconnect("click", self, "_on_mouse_click")

	_control = null
	_actors = []

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


func _on_mouse_click(_position: Vector2) -> void:
	var cell := _control.current_map.get_mouse_cell()
	for a in _actors:
		var actor := a as Actor
		if actor.on_cell(cell):
			emit_signal("_input_processed", actor)
