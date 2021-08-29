extends Node

const _MAIN_SCENE_PATH := "res://src/Main.tscn"


func _on_MainMenu_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_MAIN_SCENE_PATH)


func _on_Quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
