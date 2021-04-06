tool
class_name StateMachine
extends Node

export var initial_state: NodePath

onready var _current_state := get_node(initial_state) as State

func _get_configuration_warning() -> String:
	var result := ""

	if initial_state.is_empty():
		result = "Need to set an initial state"
	elif not get_node(initial_state) is State:
		result = "The initial state node is not a State"

	return result


func _ready() -> void:
	if not Engine.editor_hint:
		for s in get_children():
			var state := s as State
			assert(state != null)
			# warning-ignore:return_value_discarded
			state.connect("state_change_requested", self, "change_state")
		_current_state.start({})


func _unhandled_input(event: InputEvent) -> void:
	_current_state.unhandled_input(event)


func change_state(new_state: State, data := {}) -> void:
	assert(new_state.get_parent() == self)
	_current_state.end()
	_current_state = new_state
	_current_state.start(data)
