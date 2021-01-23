class_name PlayerActorTargetState
extends State

var _interface: BattleInterface
var _player: Player
var _actor: Actor
var _skill_index: int

var _have_target := false
var _skill_target: Vector2

var _move_state: State
var _chosen_action: Action = null


func _init(interface: BattleInterface, player: Player, actor: Actor,
		skill_index: int, move_state: State) -> void:
	_interface = interface
	_player = player
	_actor = actor
	_skill_index = skill_index
	_move_state = move_state


func start() -> void:
	# warning-ignore:return_value_discarded
	_interface.mouse.connect("click", self, "_mouse_click")
	# warning-ignore:return_value_discarded
	_interface.gui.connect("skill_cleared", self, "_skill_cleared")

	_interface.gui.show_skill_panel(_get_skill())

	var targeting_data := _actor.battle_stats.range_data.get_targeting_data(
			_actor.origin_cell, _skill_index)
	_interface.map_highlights.set_targets(targeting_data.target_range)
	_interface.map_highlights.moves_visible = false
	_interface.map_highlights.clear_other_moves()


func end() -> void:
	_interface.mouse.disconnect("click", self, "_mouse_click")
	_interface.gui.disconnect("skill_cleared", self, "_skill_cleared")

	_interface.gui.hide_skill_panel()

	_interface.map_highlights.target_cursor_visible = false
	_interface.map_highlights.clear_targets()
	_interface.map_highlights.moves_visible = true

	if _chosen_action:
		_player.do_action(_chosen_action)


func _skill_cleared() -> void:
	assert(_chosen_action == null)
	emit_signal("change_state", _move_state)


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _interface.current_map.get_mouse_cell()
	if _have_target:
		_confirm_target(target_cell)
	else:
		_set_target(target_cell)


func _set_target(target_cell: Vector2) -> void:
	var targeting_data := _actor.battle_stats.range_data.get_targeting_data(
			_actor.origin_cell, _skill_index)

	if target_cell in targeting_data.valid_targets:
		_interface.map_highlights.target_cursor_visible = true
		_interface.map_highlights.target_cursor_cell = target_cell

		_have_target = true
		_skill_target = target_cell


func _confirm_target(target_cell: Vector2) -> void:
	if _skill_target == target_cell:
		var skill := _get_skill()
		_chosen_action = SkillAction.new( \
				_actor, _interface.current_map, skill, target_cell)
		emit_signal("pop_state")
	else:
		_set_target(target_cell)


func _get_skill() -> Skill:
	return _actor.stats.skills[_skill_index] as Skill
