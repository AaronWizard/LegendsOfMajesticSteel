class_name PlayerTurn
extends TurnController


signal _input_processed(actor)

var _interface: BattleInterface = null
var _actors := []

func pick_actor(actors: Array, interface: BattleInterface) -> void:
	_set_actor_cursors(actors, true)

	var camera_position := _average_position(actors)
	interface.camera.move_to_position(camera_position)

	interface.mouse.dragging_enabled = true

	# warning-ignore:return_value_discarded
	interface.mouse.connect("click", self, "_on_mouse_click")

	_interface = interface
	_actors = actors

	var actor: Actor = yield(self, '_input_processed')

	interface.mouse.disconnect("click", self, "_on_mouse_click")

	_interface = null
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
	var cell := _interface.current_map.get_mouse_cell()
	for a in _actors:
		var actor := a as Actor
		if actor.on_cell(cell):
			emit_signal("_input_processed", actor)
