class_name SoundCheckButton
extends CheckButton


func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("toggled", self, "_play_press_sound")


func _play_press_sound(button_pressed: bool) -> void:
	if button_pressed:
		StandardSounds.play_select()
	else:
		StandardSounds.play_cancel()
