class_name Player
extends Controller

signal _input_processed(action)

var _map: Map = null
var _range_data: RangeData = null
var _control: BattleControl = null

func determine_action(map: Map, range_data: RangeData, control: BattleControl) -> void:
	_map = map
	_range_data = range_data
	_control = control
	_connect_to_gui(_control)

	var action: Action = yield(self, '_input_processed')

	_disconnect_from_gui(control)
	_control = null
	_range_data = null
	_map = null

	emit_signal("determined_action", action)


func _connect_to_gui(control: BattleControl) -> void:
	control.gui.buttons_visible = true
	control.mouse.dragging_enabled = true

	# warning-ignore:return_value_discarded
	#gui.connect("move_started", self, "_move")
	# warning-ignore:return_value_discarded
	#gui.connect("ability_started", self, "_target_ability")
	# warning-ignore:return_value_discarded
	#gui.connect("wait_started", self, "_wait_clicked")


func _disconnect_from_gui(control: BattleControl) -> void:
	control.gui.buttons_visible = false
	control.mouse.dragging_enabled = false

#	gui.disconnect("move_started", self, "_move")
#	gui.disconnect("ability_started", self, "_target_ability")
#	gui.disconnect("wait_started", self, "_wait_clicked")


func _move(target_cell: Vector2) -> void:
	var path := _range_data.get_walk_path(get_actor().cell, target_cell)
	if path.size() > 0:
		var action := Move.new(get_actor(), _map, path)
		#action.allow_cancel(_gui)
		emit_signal("_input_processed", action)


func _target_ability(ability: Ability, target_cell: Vector2) -> void:
	var attack := AbilityAction.new(get_actor(), _map, ability,
			target_cell)
	emit_signal("_input_processed", attack)


func _wait_clicked() -> void:
	emit_signal("_input_processed", null)
