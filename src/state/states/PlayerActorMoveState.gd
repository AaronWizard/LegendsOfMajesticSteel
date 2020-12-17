class_name PlayerActorMoveState
extends State

var _interface: BattleInterface
var _player: Player
var _actor: Actor

var _other_actor: Actor

var _doing_action := false
var _chosen_action: Action

var _action_menu_visible := false


func _init(interface: BattleInterface, player: Player, actor: Actor) -> void:
	_interface = interface
	_player = player
	_actor = actor


func start() -> void:
	_interface.mouse.dragging_enabled = true

	# warning-ignore:return_value_discarded
	_interface.mouse.connect("click", self, "_mouse_click")
	# warning-ignore:return_value_discarded
	_interface.gui.connect("wait_started", self, "_wait_started")
	# warning-ignore:return_value_discarded
	_interface.gui.connect("skill_selected", self, "_skill_selected")


func end() -> void:
	_interface.mouse.disconnect("click", self, "_mouse_click")
	_interface.gui.disconnect("wait_started", self, "_wait_started")
	_interface.gui.disconnect("skill_selected", self, "_skill_selected")

	_set_action_menu_visible(false)
	_interface.map_highlights.clear_other_moves()

	if _doing_action:
		_player.do_action(_chosen_action)


func _wait_started() -> void:
	_set_action_menu_visible(false)
	_choose_action(null)


func _skill_selected(_skill_index: int) -> void:
	var state := PlayerActorTargetState.new(_interface, _player, _actor,
			_skill_index, self)
	emit_signal("change_state", state)


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _interface.current_map.get_mouse_cell()

	if target_cell == _actor.cell:
		_set_action_menu_visible(not _action_menu_visible)
	elif not _action_menu_visible:
		var path := _actor.battle_stats.range_data.get_walk_path(
				_actor.cell, target_cell)
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
		var pos := _interface.current_map.get_screen_cell_pos(_actor.cell)
		_interface.gui.show_action_menu(pos)
	else:
		_interface.gui.hide_action_menu()


func _player_other_actor_clicked(target_cell: Vector2) -> void:
	var actor := _interface.current_map.get_actor_on_cell(target_cell)
	if (actor != null) and (actor != _actor) and (actor != _other_actor):
		_other_actor = actor
		_interface.map_highlights.set_other_moves(
				_other_actor.battle_stats.range_data.get_visible_move_range())
	else:
		_other_actor = null
		_interface.map_highlights.clear_other_moves()


func _choose_action(action: Action) -> void:
	_doing_action = true
	_chosen_action = action
	emit_signal("pop_state")
