class_name SkillEffect
extends Node

signal finished

export var delay := 0.0 # In seconds

var running: bool setget , get_is_running

var _running := false


func get_target_info(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor) -> TargetingData.TargetInfo:
	return TargetingData.TargetInfo.new()


func get_is_running() -> bool:
	return _running


func run(target_cell: Vector2, source_cell: Vector2, source_actor: Actor) \
		-> void:
	_running = true
	call_deferred("_run_main", target_cell, source_cell, source_actor)


func _run_main(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor) -> void:
	var run_state

	if delay > 0:
		yield(get_tree().create_timer(delay), "timeout")

	# warning-ignore:void_assignment
	run_state = _run_self(target_cell, source_cell, source_actor)
	if run_state is GDScriptFunctionState:
		yield(run_state, "completed")

	_running = false
	emit_signal("finished")


func _run_self(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor) -> void:
	push_warning("SkillEffect: Need to implement _run_self()")
