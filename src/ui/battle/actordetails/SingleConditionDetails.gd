class_name SingleConditionDetails
extends HBoxContainer

const _ROUND_LEFT_SINGLE := "1 round"
const _ROUNDS_LEFT_PLURAL := "%s rounds"

onready var _icon := $Icon as TextureRect
onready var _name := $Name as Label
onready var _magnitude := $Magnitude as Label

onready var _divider := $Divider as Control
onready var _rounds_left := $RoundsLeft as Label


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
	_divider.visible = true
	_rounds_left.visible = true

	if rounds_left == 0:
		_rounds_left.text = _ROUND_LEFT_SINGLE
	else:
		_rounds_left.text = _ROUNDS_LEFT_PLURAL % rounds_left


func hide_rounds_left() -> void:
	_divider.visible = false
	_rounds_left.visible = false
