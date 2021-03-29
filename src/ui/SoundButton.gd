extends Button

enum SoundButtonType { SELECT, CANCEL }

const _SELECT_SOUND := preload("res://assets/sounds/ui_select.wav")
const _CANCEL_SOUND := preload("res://assets/sounds/ui_cancel.wav")

export(SoundButtonType) var sound_type := SoundButtonType.SELECT

onready var _sound := $Sound

func _ready() -> void:
	match sound_type:
		SoundButtonType.CANCEL:
			_sound.stream = _CANCEL_SOUND
		_:
			_sound.stream = _SELECT_SOUND
	# Connecting in code to avoid cluttering the node tab
	# warning-ignore:return_value_discarded
	connect("pressed", self, "_play_press_sound")

func _play_press_sound() -> void:
	_sound.play()


func _on_SoundButton_pressed() -> void:
	pass # Replace with function body.
