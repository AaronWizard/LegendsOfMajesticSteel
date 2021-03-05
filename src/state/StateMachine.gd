class_name StateMachine
extends Node

export var initial_state: NodePath

onready var _current_state := get_node(initial_state) as State


func _ready() -> void:
	for s in get_children():
		var state := s as State
		assert(state != null)
		# warning-ignore:return_value_discarded
		state.connect("state_change_requested", self, "change_state")
	_current_state.start({})


func change_state(new_state: State, data := {}) -> void:
	assert(new_state.get_parent() == self)
	_current_state.end()
	_current_state = new_state
	_current_state.start(data)
