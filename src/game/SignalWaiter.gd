class_name SignalWaiter

signal finished

var waiting: bool setget , get_waiting

var _waiting_signals := 0


func get_waiting() -> bool:
	return _waiting_signals > 0


func wait_for_signal(obj: Object, signal_name: String) -> void:
	_waiting_signals += 1
	# warning-ignore:return_value_discarded
	obj.connect(signal_name, self, "_signal_fired", [], CONNECT_ONESHOT)


func _signal_fired() -> void:
	_waiting_signals -= 1
	if not get_waiting():
		emit_signal("finished")
