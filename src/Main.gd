extends Node

const _GAME_SCENE_PATH := "res://src/game/Game.tscn"

onready var _screen_transition := $ScreenTransition as ScreenTransition
onready var _quit_button := $HBoxContainer/Quit as CanvasItem

func _ready() -> void:
	_quit_button.visible = OS.get_name() != "HTML5"
	_screen_transition.fade_in()
	yield(_screen_transition, "faded_in")
	BackgroundMusic.start(preload("res://assets/music/start.mp3"))


func _on_Start_pressed() -> void:
	BackgroundMusic.stop()
	_screen_transition.fade_out()
	yield(_screen_transition, "faded_out")
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_GAME_SCENE_PATH)


func _on_Quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
