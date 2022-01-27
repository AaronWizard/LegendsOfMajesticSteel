class_name PlayerPickActorActionState
extends PickActorActionState


func start(_data: Dictionary) -> void:
	_game.interface.mouse.dragging_enabled = true
	# warning-ignore:return_value_discarded
	_game.interface.mouse.connect("click", self, "_mouse_click")


func end() -> void:
	_game.interface.mouse.dragging_enabled = false
	if _game.interface.mouse.is_connected("click", self, "_mouse_click"):
		_game.interface.mouse.disconnect("click", self, "_mouse_click")


func _mouse_click(_position: Vector2) -> void:
	pass
