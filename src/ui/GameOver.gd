extends Node

const _MAIN_SCENE_PATH := "res://src/Main.tscn"

onready var _quit_button := $HBoxContainer/Quit as CanvasItem


func _ready() -> void:
	_quit_button.visible = OS.get_name() != "HTML5"


func _on_MainMenu_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_MAIN_SCENE_PATH)


func _on_Quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
