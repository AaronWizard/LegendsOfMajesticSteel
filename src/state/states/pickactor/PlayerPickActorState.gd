class_name PlayerPickActorState
extends PickActorState

onready var _pick_sound := $PickSound as AudioStreamPlayer


func end() -> void:
	_game.interface.mouse.dragging_enabled = false
	if _game.interface.mouse.is_connected("click", self, "_mouse_click"):
		_game.interface.mouse.disconnect("click", self, "_mouse_click")

	_set_actor_cursors(false)

	.end()


func _get_faction() -> int:
	return Actor.Faction.PLAYER


func _choose_actor() -> void:
	_game.interface.mouse.dragging_enabled = true
	# warning-ignore:return_value_discarded
	_game.interface.mouse.connect("click", self, "_mouse_click")

	_set_actor_cursors(true)
	_position_player_turn_camera()


func _set_actor_cursors(cursor_visible: bool) -> void:
	for a in _actors:
		var actor := a as Actor
		actor.target_visible = cursor_visible


func _position_player_turn_camera() -> void:
	var average_pos := Vector2.ZERO
	for a in _actors:
		var actor := a as Actor
		average_pos += actor.position
	average_pos /= float(_actors.size())
	_game.interface.camera.move_to_position(average_pos)


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _game.interface.current_map.get_mouse_cell()
	for a in _actors:
		var actor := a as Actor
		if actor.on_cell(target_cell):
			_pick_sound.play()
			_pick_actor(actor)
			break
