class_name VictoryState
extends State

const _MAIN_SCENE_PATH := "res://src/Main.tscn"

export var victory_text_path: NodePath
export var screen_transition_path: NodePath

onready var _victory_text := get_node(victory_text_path) \
		as VictoryText
onready var _screen_transition := get_node(screen_transition_path) \
		as ScreenTransition


func start(_data: Dictionary) -> void:
	_victory_text.show_victory_text()
	yield(_victory_text, "victory_text_shown")
	_screen_transition.fade_out()
	yield(_screen_transition, "faded_out")
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_MAIN_SCENE_PATH)
