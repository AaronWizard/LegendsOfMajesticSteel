extends Node

signal finished

onready var _player := $AudioStreamPlayer as AudioStreamPlayer


func _ready() -> void:
	# warning-ignore:return_value_discarded
	_player.connect("finished", self, "_finished")


func start(music: AudioStream) -> void:
	_player.stream = music
	_player.play(0)


func stop() -> void:
	_player.stop()


func _finished() -> void:
	emit_signal("finished")
