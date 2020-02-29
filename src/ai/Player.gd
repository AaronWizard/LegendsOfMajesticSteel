class_name Player
extends Controller

signal _input_processed(action)

var _gui: BattleGUI = null


func determine_action(gui: BattleGUI) -> void:
	_gui = gui
	_connect_to_gui(gui)
	var action: Action = yield(self, '_input_processed')
	_disconnect_from_gui(gui)
	_gui = null
	emit_signal("determined_action", action)


func _connect_to_gui(gui: BattleGUI) -> void:
	gui.buttons_visible = true
	gui.dragging_enabled = true
	# warning-ignore:return_value_discarded
	gui.connect("mouse_clicked", self, "_map_clicked")
	# warning-ignore:return_value_discarded
	gui.connect("wait_pressed", self, "_wait_clicked")


func _disconnect_from_gui(gui: BattleGUI) -> void:
	gui.buttons_visible = false
	gui.dragging_enabled = false
	gui.disconnect("mouse_clicked", self, "_map_clicked")
	gui.disconnect("wait_pressed", self, "_wait_clicked")


func _map_clicked(_position) -> void:
	var target_cell := get_map().get_mouse_cell()

	var path := get_battle_stats().get_walk_path(target_cell)
	if path.size() > 0:
		var action := Move.new(get_actor(), get_map(), path)
		action.allow_cancel(_gui)
		emit_signal("_input_processed", action)


func _wait_clicked() -> void:
	get_battle_stats().finished = true
	emit_signal("_input_processed", null)
