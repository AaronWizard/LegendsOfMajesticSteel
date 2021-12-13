class_name SoundButton
extends Button

export(UISoundTypes.Types) var sound_type := UISoundTypes.Types.SELECT


func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("pressed", self, "_play_press_sound")


func _play_press_sound() -> void:
	match sound_type:
		UISoundTypes.Types.CANCEL:
			StandardSounds.play_cancel()
		_:
			StandardSounds.play_select()
