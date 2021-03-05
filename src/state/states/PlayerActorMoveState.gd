class_name PlayerActorMoveState
extends PlayerState

export var target_state_path: NodePath

var _player: Player
var _actor: Actor

var _other_actor: Actor

var _action_menu_visible := false

onready var _target_state := get_node(target_state_path) as State


func start(data: Dictionary) -> void:
	.start(data)

	_player = data.player as Player
	assert(_player)
	_actor = data.actor as Actor
	assert(_actor)

	# warning-ignore:return_value_discarded
	_interface.gui.connect("wait_started", self, "_wait_started")
	# warning-ignore:return_value_discarded
	_interface.gui.connect("skill_selected", self, "_skill_selected")


func end() -> void:
	.end()

	_interface.gui.disconnect("wait_started", self, "_wait_started")
	_interface.gui.disconnect("skill_selected", self, "_skill_selected")

	_set_action_menu_visible(false)
	_interface.clear_other_actor()

	_player = null
	_actor = null
	_other_actor = null
	_action_menu_visible = false


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _interface.current_map.get_mouse_cell()

	if _actor.on_cell(target_cell):
		_set_action_menu_visible(not _action_menu_visible)
	elif not _action_menu_visible:
		var path := _actor.range_data.get_walk_path(
				_actor.origin_cell, target_cell)
		if path.size() > 0:
			var action := Move.new(_actor, _interface.current_map, path)
			action.allow_cancel(_interface.mouse)
			_choose_action(action)
		else:
			_player_other_actor_clicked(target_cell)


func _set_action_menu_visible(visible: bool) -> void:
	_action_menu_visible = visible
	_interface.mouse.dragging_enabled = not _action_menu_visible

	if _action_menu_visible:
		var pos := _actor.center_screen_pos
		_interface.gui.show_action_menu(pos)

		var menu_pos := _interface.gui.get_action_menu_pos()
		if menu_pos != pos:
			var diff := menu_pos - pos
			_interface.camera.position = _interface.camera.get_camera_position()
			_interface.camera.move_to_position(
					_interface.camera.position - diff, false)
	else:
		_interface.gui.hide_action_menus()


func _player_other_actor_clicked(target_cell: Vector2) -> void:
	var other_actor := _interface.current_map.get_actor_on_cell(target_cell)
	if (other_actor != null) and (other_actor != _actor) \
			and (other_actor != _other_actor):
		_other_actor = other_actor
		_interface.set_other_actor(other_actor)
	else:
		_other_actor = null
		_interface.clear_other_actor()


func _wait_started() -> void:
	_set_action_menu_visible(false)
	_choose_action(null)


func _skill_selected(skill_index: int) -> void:
	emit_signal("state_change_requested", _target_state, {
		player = _player, actor = _actor, skill_index = skill_index
	})


func _choose_action(action: Action) -> void:
	_player.do_action(action)
