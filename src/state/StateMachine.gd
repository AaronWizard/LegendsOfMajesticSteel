class_name StateMachine

var _current_state: State = null


func change_state(new_state: State) -> void:
	if _current_state != null:
		 _end_state()

	_current_state = new_state

	if _current_state != null:
		_start_state()


func pop_state() -> void:
	_end_state()


func _start_state() -> void:
	# warning-ignore:return_value_discarded
	_current_state.connect("change_state", self, "change_state")
	# warning-ignore:return_value_discarded
	_current_state.connect("pop_state", self, "pop_state")

	_current_state.start()


func _end_state() -> void:
	var old_state := _current_state
	_current_state = null

	old_state.disconnect("change_state", self, "change_state")
	old_state.disconnect("pop_state", self, "pop_state")
	old_state.end()
