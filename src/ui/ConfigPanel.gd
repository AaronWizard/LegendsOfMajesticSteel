extends PanelContainer


onready var _video_options := $VBoxContainer/VideoOptions as Control


func _ready() -> void:
	_video_options.visible = OS.get_name() != "HTML5"


func _on_FullscreenToggle_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed


func _on_SoundVolume_value_changed(value: float) -> void:
	var volume := linear2db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), volume)
	StandardSounds.play_select()


func _on_MusicVolume_value_changed(value: float) -> void:
	var volume := linear2db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume)
