class_name SignalWaiter

signal finished

var waiting: bool setget , get_waiting
var _waiting_objs := []


func get_waiting() -> bool:
	return not _waiting_objs.empty()


func wait_for_signal(obj: Object, signal_name: String) -> void:
	_waiting_objs.append([obj, signal_name])
	# warning-ignore:return_value_discarded
	obj.connect(signal_name, self, "_signal_fired", [obj, signal_name])


func _signal_fired(obj: Object, signal_name: String) -> void:
	# Originally I was making the original connection a oneshot. For some reason
	# though I started getting "Disconnecting nonexistent signal" errors until
	# I switched to manually disconnecting the signal
	for i in range(_waiting_objs.size()):
		var index := i as int
		var pair := _waiting_objs[index] as Array

		var old_obj := pair[0] as Object
		var old_signal_name := pair[1] as String
		if (old_obj == obj) and (old_signal_name == signal_name):
			_waiting_objs.remove(index)
			obj.disconnect(signal_name, self, "_signal_fired")
			break

	if not get_waiting():
		emit_signal("finished")
