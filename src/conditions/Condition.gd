class_name Condition

signal finished

enum EffectTimeType {
	ROUNDS,
	INDEFINITE
}

var effect: ConditionEffect
var effect_time_type: int = EffectTimeType.ROUNDS
var rounds_left := 1


func _init(new_effect: ConditionEffect, new_type: int, rounds: int) -> void:
	effect = new_effect
	effect_time_type = new_type
	rounds_left = rounds


func start_round() -> void:
	if effect_time_type == EffectTimeType.ROUNDS:
		if rounds_left == 0:
			emit_signal("finished")
		else:
			rounds_left -= 1
