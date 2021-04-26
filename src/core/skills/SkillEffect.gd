class_name SkillEffect
extends Node

signal finished

var running: bool setget , get_is_running

var _running := false


# Array of Vector2
func get_aoe(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, _map: Map) -> Array:
	return []


# Keys are actors, values are ints
# Negative values are damage, positive values are healing
func predict_damage(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, _map: Map) -> Dictionary:
	return {}


# Keys are actors, values arrays of condition effects
func predict_conditions(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, _map: Map) -> Dictionary:
	return {}


func get_is_running() -> bool:
	return _running


func run(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	_running = true
	call_deferred("_run_main", target_cell, source_cell, source_actor, map)


func _run_main(target_cell: Vector2, source_cell: Vector2,
		source_actor: Actor, map: Map) -> void:
	var run_state
	# warning-ignore:void_assignment
	run_state = _run_self(target_cell, source_cell, source_actor, map)
	if run_state is GDScriptFunctionState:
		yield(run_state, "completed")

	_running = false
	emit_signal("finished")


func _run_self(_target_cell: Vector2, _source_cell: Vector2,
		_source_actor: Actor, _map: Map):
	push_warning("SkillEffect: Need to implement _run_self()")
