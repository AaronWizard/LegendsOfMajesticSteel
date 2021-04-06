class_name PickActorActionState
extends GameState

export var move_state_path: NodePath
export var skill_state_path: NodePath
export var turn_start_state_path: NodePath

onready var _move_state := get_node(move_state_path) as State
onready var _skill_state := get_node(skill_state_path) as State
onready var _turn_start_state := get_node(turn_start_state_path) as State


func _do_move(path: Array) -> void:
	emit_signal("state_change_requested", _move_state, { path = path })


func _do_skill(skill: Skill, target: Vector2) -> void:
	emit_signal(
		"state_change_requested", _skill_state,
		{ skill = skill, target = target }
	)


func _do_wait() -> void:
	_game.current_actor.take_turn()
	emit_signal("state_change_requested", _turn_start_state)
