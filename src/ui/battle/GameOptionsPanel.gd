extends PopupPanel

const _MAIN_SCENE_PATH := "res://src/Main.tscn"

const _MAIN_MENU_CONFIRM := "Are you sure you want to return to the main menu?"
const _QUIT_CONFIRM := "Are you sure you want to quit?"

onready var _quit := $VBoxContainer/Quit as CanvasItem

onready var _config_panel := $ConfigPanel as Popup
onready var _yes_no_panel := $YesNoDialog as YesNoDialog


func _ready() -> void:
	_quit.visible = OS.get_name() != "HTML5"
	rect_size = Vector2.ZERO


func _on_Options_pressed() -> void:
	_config_panel.popup_centered()


func _on_MainMenu_pressed() -> void:
	_yes_no_panel.text = _MAIN_MENU_CONFIRM
	_yes_no_panel.popup_centered()

	var quit := yield(_yes_no_panel, "closed") as bool
	if quit:
		BackgroundMusic.stop()
		# warning-ignore:return_value_discarded
		get_tree().change_scene(_MAIN_SCENE_PATH)


func _on_Quit_pressed() -> void:
	_yes_no_panel.text = _QUIT_CONFIRM
	_yes_no_panel.popup_centered()

	var quit := yield(_yes_no_panel, "closed") as bool
	if quit:
		get_tree().quit()


func _on_Back_pressed() -> void:
	visible = false
