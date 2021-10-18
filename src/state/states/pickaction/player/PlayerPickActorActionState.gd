class_name PlayerPickActorActionState
extends PickActorActionState

export var pick_actor_state_path: NodePath

onready var pick_actor_state := get_node(pick_actor_state_path) as State


func start(_data: Dictionary) -> void:
	_game.interface.mouse.dragging_enabled = true
	# warning-ignore:return_value_discarded
	_game.interface.mouse.connect("click", self, "_mouse_click")

	# warning-ignore:return_value_discarded
	_game.interface.gui.connect("turn_cancelled", self, "_turn_cancelled")


func end() -> void:
	_game.interface.mouse.dragging_enabled = false
	if _game.interface.mouse.is_connected("click", self, "_mouse_click"):
		_game.interface.mouse.disconnect("click", self, "_mouse_click")

	_game.interface.gui.disconnect("turn_cancelled", self, "_turn_cancelled")


func _mouse_click(_position: Vector2) -> void:
	pass


func _turn_cancelled() -> void:
	var actor := _game.current_actor
	_game.cancel_turn()

	var path := actor.walk_range.get_walk_path(
			actor.origin_cell,
			actor.walk_range.origin_cell,
			false
	)
	if path.size() > 0:
		_game.interface.mouse.dragging_enabled = false
		_game.interface.mouse.disconnect("click", self, "_mouse_click")
		yield(actor.move_path(path), "completed")

	_game.refresh_walk_ranges(true)
	emit_signal("state_change_requested", pick_actor_state)