class_name Condition

signal finished

var effect: ConditionEffect

var rounds_left := 1


func _init(new_effect: ConditionEffect) -> void:
	effect = new_effect
	rounds_left = effect.max_rounds


func start_round() -> void:
	if effect.time_type == ConditionEffect.TimeType.ROUNDS:
		if rounds_left == 0:
			emit_signal("finished")
		else:
			rounds_left -= 1
