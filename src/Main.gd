extends Node

const _GAME_SCENE_PATH := "res://src/game/Game.tscn"

onready var _screen_transition := $ScreenTransition as ScreenTransition


func _ready() -> void:
	_screen_transition.fade_in()
	yield(_screen_transition, "faded_in")


func _on_Start_pressed() -> void:
	_screen_transition.fade_out()
	yield(_screen_transition, "faded_out")
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_GAME_SCENE_PATH)
