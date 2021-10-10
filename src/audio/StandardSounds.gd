extends Node

onready var _select := $Select as AudioStreamPlayer
onready var _cancel := $Cancel as AudioStreamPlayer


func play_select() -> void:
	_select.play()


func play_cancel() -> void:
	_cancel.play()
