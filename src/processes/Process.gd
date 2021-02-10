class_name Process

signal finished

var children := []
var concurrent_children := false

var _waiter := SignalWaiter.new()


func run() -> void:
	call_deferred("_run_main")


func _run_main() -> void:
	var run_state

	# warning-ignore:void_assignment
	run_state = _run_self()
	if run_state is GDScriptFunctionState:
		yield(run_state, "completed")

	run_state = _run_children()
	if run_state is GDScriptFunctionState:
		yield(run_state, "completed")

	emit_signal("finished")


func _run_children() -> void:
	for c in children:
		var child := c as Process
		child.run()
		if concurrent_children:
			_waiter.wait_for_signal(child, "finished")
		else:
			yield(child, "finished")

	if _waiter.waiting:
		yield(_waiter, "finished")


func _run_self() -> void:
	print("Process: Must implement _run_self()")
