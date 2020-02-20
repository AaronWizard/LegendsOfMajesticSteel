class_name BattleGUI
extends CanvasLayer

signal wait_pressed

var buttons_visible := false setget set_buttons_visible

onready var _all_buttons: Control = get_node("Buttons")


func set_buttons_visible(value: bool) -> void:
	_all_buttons.visible = value


func _on_Wait_pressed() -> void:
	emit_signal("wait_pressed")
