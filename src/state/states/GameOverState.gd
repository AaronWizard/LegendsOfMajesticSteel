class_name GameOverState
extends State

export var screen_transition_path: NodePath

onready var _screen_transition := get_node(screen_transition_path) \
		as ScreenTransition


func start(_data: Dictionary) -> void:
	_screen_transition.fade_out()
	yield(_screen_transition, "faded_out")
