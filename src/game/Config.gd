extends Node

const _CONFIG_FILE := "user://config.cfg"

const _CONFIG_RESOLUTION := "resolution"
const _CONFIG_FULLSCREEN := "fullscreen"
const _CONFIG_SOUND_VOLUME := "sound_volume"
const _CONFIG_MUSIC_VOLUME := "music_volume"
const _CONFIG_UI_VOLUME := "ui_volume"

var resolution: Vector2 setget set_resolution
var fullscreen: bool setget set_fullscreen

var sound_volume: float setget set_sound_volume
var music_volume: float setget set_music_volume
var ui_volume: float setget set_ui_volume


func _ready() -> void:
	_load()
	# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_on_screen_resized")


func set_resolution(value: Vector2) -> void:
	resolution = value
	_save_single_setting(_CONFIG_RESOLUTION, resolution)
	_set_window_properties()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_save_single_setting(_CONFIG_FULLSCREEN, fullscreen)
	_set_window_properties()


# Volume is value from 0 to 1
func set_sound_volume(value: float) -> void:
	sound_volume = value
	_save_single_setting(_CONFIG_SOUND_VOLUME, sound_volume)
	_set_volume(value, Constants.SOUND_BUS)


# Volume is value from 0 to 1
func set_music_volume(value: float) -> void:
	music_volume = value
	_save_single_setting(_CONFIG_MUSIC_VOLUME, music_volume)
	_set_volume(value, Constants.MUSIC_BUS)


func set_ui_volume(value: float) -> void:
	ui_volume = value
	_save_single_setting(_CONFIG_UI_VOLUME, ui_volume)
	_set_volume(value, Constants.UI_BUS)


func _load() -> void:
	var config := ConfigFile.new()
	var load_err := config.load(_CONFIG_FILE)

	if load_err != OK:
		config.clear()

	resolution = config.get_value("", _CONFIG_RESOLUTION,
			OS.get_screen_size() / 2)
	fullscreen = config.get_value("", _CONFIG_FULLSCREEN, false)

	sound_volume = config.get_value("", _CONFIG_SOUND_VOLUME, 1.0)
	music_volume = config.get_value("", _CONFIG_MUSIC_VOLUME, 1.0)
	ui_volume = config.get_value("", _CONFIG_UI_VOLUME, 1.0)

	if load_err != OK:
		config.set_value("", _CONFIG_RESOLUTION, resolution)
		config.set_value("", _CONFIG_FULLSCREEN, fullscreen)

		config.set_value("", _CONFIG_SOUND_VOLUME, sound_volume)
		config.set_value("", _CONFIG_MUSIC_VOLUME, music_volume)
		config.set_value("", _CONFIG_UI_VOLUME, ui_volume)

		var save_err := config.save(_CONFIG_FILE)
		if save_err != OK:
			push_error("Could not save config file '%s'" % _CONFIG_FILE)

	_set_window_properties()
	_set_volume(sound_volume, Constants.SOUND_BUS)
	_set_volume(music_volume, Constants.MUSIC_BUS)
	_set_volume(ui_volume, Constants.UI_BUS)


func _on_screen_resized() -> void:
	resolution = OS.window_size
	_save_single_setting(_CONFIG_RESOLUTION, resolution)


func _save_single_setting(key: String, value) -> void:
	var config := ConfigFile.new()
	var err := config.load(_CONFIG_FILE)
	if err != OK:
		push_error("Could not load config file '%s'" % _CONFIG_FILE)
	else:
		config.set_value("", key, value)
		err = config.save(_CONFIG_FILE)
		if err != OK:
			push_error("Could not save setting %s to config file '%s'"
					% [key, _CONFIG_FILE])


func _set_window_properties() -> void:
	OS.window_fullscreen = fullscreen
	OS.window_size = resolution
	OS.center_window()


func _set_volume(volume: float, bus_name: String) -> void:
	var volume_db := linear2db(volume)
	var bus_index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
