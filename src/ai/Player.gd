class_name Player
extends Controller

signal _input_processed(action)


func _ready() -> void:
	._ready()
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var target_cell := get_map().get_mouse_cell()

		var path := get_battle_stats().get_walk_path(target_cell)
		if path.size() > 0:
			var action := MoveAction.new()
			action.actor = get_actor()
			action.map = get_map()
			action.path = path

			emit_signal("_input_processed", action)


func connect_to_gui(gui: BattleGUI) -> void:
	gui.buttons_visible = true
	# warning-ignore:return_value_discarded
	gui.connect("wait_pressed", self, "_wait_clicked")


func disconnect_from_gui(gui: BattleGUI) -> void:
	gui.buttons_visible = false
	gui.disconnect("wait_pressed", self, "_wait_clicked")


func determine_action() -> void:
	set_process_unhandled_input(true)
	var action: Action = yield(self, '_input_processed')
	set_process_unhandled_input(false)
	emit_signal("determined_action", action)


func _wait_clicked() -> void:
	get_battle_stats().finished = true
	emit_signal("_input_processed", null)
