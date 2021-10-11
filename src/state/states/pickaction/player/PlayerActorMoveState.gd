class_name PlayerActorMoveState
extends PlayerPickActorActionState

export var player_target_state_path: NodePath

var _other_actor: Actor

onready var _player_target_state := get_node(player_target_state_path) as State


func start(data: Dictionary) -> void:
	.start(data)

	# warning-ignore:return_value_discarded
	_game.interface.gui.connect("wait_started", self, "_wait_started")
	# warning-ignore:return_value_discarded
	_game.interface.gui.connect("skill_selected", self, "_skill_selected")

	# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_screen_resized")


func end() -> void:
	.end()

	_game.interface.gui.close_action_menu(false)
	_game.interface.gui.disconnect("wait_started", self, "_wait_started")
	_game.interface.gui.disconnect("skill_selected", self, "_skill_selected")

	get_tree().disconnect("screen_resized", self, "_screen_resized")
	_game.interface.clear_other_actor()

	_other_actor = null


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _game.interface.current_map.get_mouse_cell()

	if _game.current_actor.on_cell(target_cell):
		_toggle_action_menu()
	elif not _game.interface.gui.action_menu_open:
		var path := _game.current_actor.walk_range.get_walk_path(
				_game.current_actor.origin_cell, target_cell, true)
		if path.size() > 0:
			_do_move(path)
		else:
			_player_other_actor_clicked(target_cell)


func _toggle_action_menu() -> void:
	if not _game.interface.gui.action_menu_open:
		_game.interface.gui.open_action_menu()
		_position_action_menu()
		_game.interface.mouse.dragging_enabled = false
	else:
		_game.interface.gui.close_action_menu()
		_game.interface.mouse.dragging_enabled = true


func _player_other_actor_clicked(target_cell: Vector2) -> void:
	var other_actor := _game.interface.current_map.get_actor_on_cell(
			target_cell)
	if (other_actor != null) and (other_actor != _game.current_actor) \
			and (other_actor != _other_actor):
		_other_actor = other_actor
		_game.interface.set_other_actor(other_actor)
	else:
		_other_actor = null
		_game.interface.clear_other_actor()


func _wait_started() -> void:
	_do_wait()


func _skill_selected(skill_index: int) -> void:
	_game.interface.gui.close_action_menu(false)
	emit_signal(
		"state_change_requested",
		_player_target_state, { skill_index = skill_index }
	)


func _position_action_menu() -> void:
	var pos := _game.current_actor.center_screen_pos
	_game.interface.gui.action_menu_position = pos

	var menu_pos := _game.interface.gui.action_menu_position
	if menu_pos != pos:
		var diff := menu_pos - pos
		_game.interface.camera.position = \
				_game.interface.camera.get_camera_position()
		_game.interface.camera.move_to_position(
				_game.interface.camera.position - diff, false)


func _screen_resized() -> void:
	if _game.interface.gui.action_menu_open:
		_position_action_menu()
