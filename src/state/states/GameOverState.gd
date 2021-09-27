class_name GameOverState
extends State

const _GAME_OVER_SCENE := "res://src/ui/GameOver.tscn"

export var screen_transition_path: NodePath

onready var _screen_transition := get_node(screen_transition_path) \
		as ScreenTransition


func start(_data: Dictionary) -> void:
	BackgroundMusic.stop()

	_screen_transition.fade_out()
	yield(_screen_transition, "faded_out")
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_GAME_OVER_SCENE)
