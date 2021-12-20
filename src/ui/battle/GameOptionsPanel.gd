extends PopupPanel

onready var _config_panel := $ConfigPanel as PopupPanel


func _on_Options_pressed() -> void:
	_config_panel.popup_centered()


func _on_MainMenu_pressed() -> void:
	pass # Replace with function body.


func _on_Quit_pressed() -> void:
	pass # Replace with function body.


func _on_Back_pressed() -> void:
	visible = false
