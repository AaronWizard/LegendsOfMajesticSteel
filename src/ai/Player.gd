class_name Player
extends Controller

signal _input_processed(action)


func connect_to_gui(gui: BattleGUI) -> void:
	gui.buttons_visible = true
	# warning-ignore:return_value_discarded
	gui.connect("mouse_clicked", self, "_map_clicked")
	# warning-ignore:return_value_discarded
	gui.connect("wait_pressed", self, "_wait_clicked")


func disconnect_from_gui(gui: BattleGUI) -> void:
	gui.buttons_visible = false
	gui.disconnect("mouse_clicked", self, "_map_clicked")
	gui.disconnect("wait_pressed", self, "_wait_clicked")


func determine_action() -> void:
	var action: Action = yield(self, '_input_processed')
	emit_signal("determined_action", action)


func _map_clicked(_position) -> void:
	var target_cell := get_map().get_mouse_cell()

	var path := get_battle_stats().get_walk_path(target_cell)
	if path.size() > 0:
		var action := MoveAction.new(get_actor(), get_map(), path)
		emit_signal("_input_processed", action)


func _wait_clicked() -> void:
	get_battle_stats().finished = true
	emit_signal("_input_processed", null)
