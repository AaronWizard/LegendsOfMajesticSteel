extends Node

onready var _player := $AudioStreamPlayer as AudioStreamPlayer

func start(music: AudioStream) -> void:
	_player.stream = music
	_player.play(0)


func stop() -> void:
	_player.stop()
