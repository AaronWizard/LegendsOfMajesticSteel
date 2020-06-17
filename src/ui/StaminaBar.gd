class_name StaminaBar
extends Node2D

signal animation_finished

const _CHANGE_PER_SECOND := 0.05
const _CHANGE_DELAY := 0.2

var modifier := 0.0 setget _set_modifier

var _current_value: float

onready var _stamina_front := $Background/StaminaFront as Range
onready var _stamina_back := $Background/StaminaBack as Range
onready var _tween := $Tween as Tween
onready var _prediction_timer := $PredictionTimer as Timer


func _ready() -> void:
	_current_value = _stamina_front.value


func animate_change(delta: float) -> void:
	_set_modifier(0)

	_current_value = clamp(_current_value + delta,
			_stamina_front.min_value, _stamina_front.max_value)

	var old_stamina := _stamina_front.value

	if delta < 0:
		_stamina_front.value = _current_value
		_animate_bar(_stamina_back, old_stamina, _current_value)
	else:
		_stamina_back.value = _current_value
		_animate_bar(_stamina_front, old_stamina, _current_value)


func _animate_bar(bar: Range, old_value: float, new_value: float) -> void:
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			bar, "value", old_value, new_value,
			abs(new_value - old_value) * _CHANGE_PER_SECOND,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, _CHANGE_DELAY)
	# warning-ignore:return_value_discarded
	_tween.start()


func _on_Tween_tween_all_completed() -> void:
	emit_signal("animation_finished")


func _set_modifier(new_value: float) -> void:
	modifier = new_value

	_stamina_front.value = _current_value
	_stamina_back.value = _current_value

	_prediction_timer.start()


func _on_PredictionTimer_timeout() -> void:
	if modifier > 0:
		_stamina_back.value = _get_alternating_value(_stamina_back.value)
	elif modifier < 0:
		_stamina_front.value = _get_alternating_value(_stamina_front.value)
	else:
		_stamina_front.value = _current_value
		_stamina_back.value = _current_value
		_prediction_timer.stop()


func _get_alternating_value(current: float) -> float:
	var result := _current_value
	if current == _current_value:
		result += modifier
	return result
