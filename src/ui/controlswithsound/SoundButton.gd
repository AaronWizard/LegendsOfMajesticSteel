class_name SoundButton
extends Button

enum SoundButtonType { SELECT, CANCEL }

export(SoundButtonType) var sound_type := SoundButtonType.SELECT

func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("pressed", self, "_play_press_sound")

func _play_press_sound() -> void:
	match sound_type:
		SoundButtonType.CANCEL:
			StandardSounds.play_cancel()
		_:
			StandardSounds.play_select()
