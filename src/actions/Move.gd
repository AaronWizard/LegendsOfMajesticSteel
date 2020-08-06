class_name Move
extends Action

var path: Array


func _init(new_actor: Actor, new_map: Map, new_path: Array) \
		.(new_actor, new_map) -> void:
	path = new_path


func show_map_highlights() -> bool:
	return true


func start() -> void:
	call_deferred("_move_step")


func _move_step() -> void:
	if path.size() > 0:
		var cell: Vector2 = path.pop_front()
		actor.move_step(cell)
		yield(actor, "move_finished")
		call_deferred("_move_step")
	else:
		emit_signal("finished")


func allow_cancel(mouse: MouseControl) -> void:
	# warning-ignore:return_value_discarded
	mouse.connect("click", self, "_click_to_cancel", [], CONNECT_ONESHOT)
	# In case move not cancelled
	# warning-ignore:return_value_discarded
	connect("finished", self, "_disconnect_from_mouse",
			[mouse], CONNECT_ONESHOT)


func _disconnect_from_mouse(mouse: MouseControl) -> void:
	if mouse.is_connected("click", self, "_click_to_cancel"):
		mouse.disconnect("click", self, "_click_to_cancel")


func _click_to_cancel(_position) -> void:
	path.clear()
