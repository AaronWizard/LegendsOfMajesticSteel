class_name SingleConditionDetails
extends VBoxContainer

const _ROUNDS_LEFT_TEXT := "%s rounds"

onready var _icon := $ConditionDescription/Icon as TextureRect
onready var _name := $ConditionDescription/Name as Label
onready var _magnitude := $ConditionDescription/Magnitude as Label

onready var _rounds_left := $ConditionValues/RoundsLeft as Label


func set_condition_icon(value: Texture) -> void:
	_icon.texture = value


func set_condition_name(value: String) -> void:
	_name.text = value


func set_magnitude(magnitude: int, is_percentage := false) -> void:
	var text := str(magnitude)
	if is_percentage:
		text += "%"
	_magnitude.text = text


func show_rounds_left(rounds_left: int) -> void:
	_rounds_left.visible = true
	_rounds_left.text = _ROUNDS_LEFT_TEXT % rounds_left


func hide_rounds_left() -> void:
	_rounds_left.visible = false
