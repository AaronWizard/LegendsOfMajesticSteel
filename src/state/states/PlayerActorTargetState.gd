class_name PlayerActorTargetState
extends State

var _interface: BattleInterface
var _player: Player
var _actor: Actor
var _ability_index: int

var _have_target := false
var _ability_target: Vector2

var _move_state: State
var _chosen_action: Action = null


func _init(interface: BattleInterface, player: Player, actor: Actor,
		ability_index: int, move_state: State) -> void:
	_interface = interface
	_player = player
	_actor = actor
	_ability_index = ability_index
	_move_state = move_state


func start() -> void:
	# warning-ignore:return_value_discarded
	_interface.mouse.connect("click", self, "_mouse_click")
	# warning-ignore:return_value_discarded
	_interface.gui.connect("ability_cleared", self, "_ability_cleared")

	var targeting_data := _actor.battle_stats.range_data.get_targeting_data(
			_actor.cell, _ability_index)
	_interface.map_highlights.set_targets(targeting_data.target_range)
	_interface.map_highlights.moves_visible = false
	_interface.map_highlights.clear_other_moves()


func end() -> void:
	_interface.mouse.disconnect("click", self, "_mouse_click")
	_interface.gui.disconnect("ability_cleared", self, "_ability_cleared")
	_interface.gui.current_ability_index = -1

	_interface.map_highlights.target_cursor_visible = false
	_interface.map_highlights.clear_targets()
	_interface.map_highlights.moves_visible = true

	if _chosen_action:
		_player.do_action(_chosen_action)


func _ability_cleared() -> void:
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
			_actor.cell, _interface.gui.current_ability_index)

	if target_cell in targeting_data.valid_targets:
		_interface.map_highlights.target_cursor_visible = true
		_interface.map_highlights.target_cursor_cell = target_cell

		_have_target = true
		_ability_target = target_cell


func _confirm_target(target_cell: Vector2) -> void:
	if _ability_target == target_cell:
		var ability := _actor.stats.abilities[ \
				_interface.gui.current_ability_index] as Ability
		_chosen_action = AbilityAction.new( \
				_actor, _interface.current_map, ability, target_cell)
		emit_signal("pop_state")
	else:
		_set_target(target_cell)
