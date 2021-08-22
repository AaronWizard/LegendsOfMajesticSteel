extends Node

const _GAME_SCENE_PATH := "res://src/game/Game.tscn"


func _on_Start_pressed() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_GAME_SCENE_PATH)
