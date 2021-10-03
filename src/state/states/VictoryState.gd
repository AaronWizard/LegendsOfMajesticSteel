class_name VictoryState
extends State

const _MAIN_SCENE_PATH := "res://src/Main.tscn"

export var victory_text_path: NodePath
export var screen_transition_path: NodePath

onready var _victory_text := get_node(victory_text_path) \
		as VictoryText
onready var _screen_transition := get_node(screen_transition_path) \
		as ScreenTransition

var _can_quit := false


func start(_data: Dictionary) -> void:
	_can_quit = false

	BackgroundMusic.stop()
	_victory_text.show_victory_text()
	yield(_victory_text, "victory_text_shown")

	_can_quit = true

	BackgroundMusic.start(preload("res://assets/music/victory.mp3"))
	yield(BackgroundMusic, "finished")
	_end_victory()


func unhandled_input(event: InputEvent) -> void:
	var is_key := (event is InputEventMouseButton) \
			and (event as InputEventMouseButton).pressed
	var is_mouse := (event is InputEventKey) \
			and (event as InputEventKey).pressed
	if _can_quit and (is_key or is_mouse):
		_end_victory()


func _end_victory() -> void:
	BackgroundMusic.stop()
	_screen_transition.fade_out()
	yield(_screen_transition, "faded_out")
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_MAIN_SCENE_PATH)
