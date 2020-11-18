class_name Player
extends ActorController

signal _input_processed(action)

enum State {
	MOVEMENT,
	ABILITY_TARGETING,
	ABILITY_CONFIRMATION
}

var _actor: Actor = null
var _map: Map = null
var _range_data: RangeData = null
var _interface: BattleInterface = null

var _state: int

var _ability_targetting: Ability.TargetingData
var _ability_target: Vector2

func determine_action(actor: Actor, map: Map, range_data: RangeData,
		interface: BattleInterface) -> void:
	_actor = actor
	_map = map
	_range_data = range_data
	_interface = interface
	_connect_to_gui()

	_state = State.MOVEMENT

	var action: Action = yield(self, '_input_processed')

	_disconnect_from_gui()
	_interface = null
	_range_data = null
	_map = null
	_actor = null

	_ability_targetting = null

	emit_signal("determined_action", action)


func _connect_to_gui() -> void:
	_interface.gui.buttons_visible = true
	_interface.mouse.dragging_enabled = true

	# warning-ignore:return_value_discarded
	_interface.mouse.connect("click", self, "_mouse_click")

	# warning-ignore:return_value_discarded
	_interface.gui.connect("ability_selected", self, "_ability_selected")
	# warning-ignore:return_value_discarded
	_interface.gui.connect("ability_cleared", self, "_ability_cleared")
	# warning-ignore:return_value_discarded
	_interface.gui.connect("wait_started", self, "_wait_clicked")


func _disconnect_from_gui() -> void:
	_interface.mouse.disconnect("click", self, "_mouse_click")

	_interface.gui.disconnect("ability_selected", self, "_ability_selected")
	_interface.gui.disconnect("ability_cleared", self, "_ability_cleared")
	_interface.gui.disconnect("wait_started", self, "_wait_clicked")


func _mouse_click(_position) -> void:
	var target_cell := _map.get_mouse_cell()

	match _state:
		State.MOVEMENT:
			_move(target_cell)
		State.ABILITY_TARGETING:
			_set_target(target_cell)
		State.ABILITY_CONFIRMATION:
			_confirm_ability_target(target_cell)


func _move(target_cell: Vector2) -> void:
	var path := _range_data.get_walk_path(_actor.cell, target_cell)
	if path.size() > 0:
		var action := Move.new(_actor, _map, path)
		action.allow_cancel(_interface.mouse)
		emit_signal("_input_processed", action)


func _set_target(target_cell: Vector2) -> void:
	if target_cell in _ability_targetting.valid_targets:
		_ability_target = target_cell
		_interface.set_target(target_cell)

		_state = State.ABILITY_CONFIRMATION


func _confirm_ability_target(target_cell: Vector2) -> void:
	if _ability_target == target_cell:
		var ability := AbilityAction.new(_actor, _map,
				_interface.gui.current_ability, target_cell)

		_interface.gui.current_ability = null
		emit_signal("_input_processed", ability)
	else:
		_set_target(target_cell)


func _ability_selected(ability: Ability) -> void:
	_ability_targetting = ability.get_targeting_data(_actor.cell, _actor, _map)
	_state = State.ABILITY_TARGETING


func _ability_cleared() -> void:
	_ability_targetting = null
	_state = State.MOVEMENT


func _wait_clicked() -> void:
	emit_signal("_input_processed", null)
