class_name StaminaBar
extends Node2D

signal animation_finished

const _CHANGE_PER_SECOND := 0.1
const _CHANGE_DELAY := 0.25

var max_stamina := 20 setget _set_max_stamina, _get_max_stamina
var modifier := 0.0 setget _set_modifier

var _current_value: float

onready var _stamina_front := $Background/StaminaFront as Range
onready var _stamina_back := $Background/StaminaBack as Range
onready var _tween := $Tween as Tween
onready var _prediction_timer := $PredictionTimer as Timer


func reset() -> void:
	_current_value = float(_get_max_stamina())
	_stamina_front.value = _current_value


func animate_change(delta: float) -> void:
	_set_modifier(0)

	var old_stamina := _current_value
	_current_value = clamp(_current_value + delta,
			_stamina_front.min_value, _stamina_front.max_value)

	if delta < 0:
		_stamina_front.value = _current_value
		_animate_bar(_stamina_back, old_stamina, _current_value)
	else:
		_stamina_back.value = _current_value
		_animate_bar(_stamina_front, old_stamina, _current_value)


func _animate_bar(bar: Range, old_value: float, new_value: float) -> void:
	bar.value = old_value

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			bar, "value", old_value, new_value,
			abs(new_value - old_value) * _CHANGE_PER_SECOND,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, _CHANGE_DELAY)
	# warning-ignore:return_value_discarded
	_tween.start()


func _on_Tween_tween_all_completed() -> void:
	yield(get_tree().create_timer(_CHANGE_DELAY), "timeout")
	emit_signal("animation_finished")


func _set_max_stamina(new_value: int) -> void:
	_stamina_front.max_value = new_value
	_stamina_back.max_value = new_value


func _get_max_stamina() -> int:
	return int(_stamina_front.max_value)


func _set_modifier(new_value: float) -> void:
	modifier = new_value

	_stamina_front.value = _current_value
	_stamina_back.value = _current_value

	if modifier != 0:
		_prediction_timer.start()
	else:
		_prediction_timer.stop()


func _on_PredictionTimer_timeout() -> void:
	assert(modifier != 0)

	if modifier > 0:
		_stamina_back.value = _get_alternating_value(_stamina_back.value)
	else: #if modifier < 0:
		_stamina_front.value = _get_alternating_value(_stamina_front.value)


func _get_alternating_value(current: float) -> float:
	var result := _current_value
	if current == _current_value:
		result += modifier
	return result
