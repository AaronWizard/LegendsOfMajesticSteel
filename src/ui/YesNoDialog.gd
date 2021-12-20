class_name YesNoDialog
extends PopupPanel

signal closed(yes_clicked)


var text := "" setget set_text, get_text

onready var _label := $VBoxContainer/MarginContainer/Label as Label

func set_text(value: String) -> void:
	if _label:
		_label.text = value


func get_text() -> String:
	var result: String

	if _label:
		result = _label.text

	return result


func _on_Yes_pressed() -> void:
	_clicked(true)


func _on_No_pressed() -> void:
	_clicked(false)


func _clicked(yes_clicked: bool) -> void:
	visible = false
	emit_signal("closed", yes_clicked)
