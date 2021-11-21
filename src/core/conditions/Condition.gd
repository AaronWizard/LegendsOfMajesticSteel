class_name Condition

signal finished

var effect: ConditionDefinition

var rounds_left := 1

var stat_modifiers: Array setget , get_stat_modifiers

func _init(new_effect: ConditionDefinition) -> void:
	effect = new_effect
	rounds_left = effect.max_rounds


func start_round() -> void:
	if effect.time_type == ConditionDefinition.TimeType.ROUNDS:
		if rounds_left == 0:
			emit_signal("finished")
		else:
			rounds_left -= 1


func get_stat_modifiers() -> Array:
	return effect.stat_modifiers


func get_stat_modifiers_by_type(stat_type: int) -> Array:
	return effect.get_modifiers_by_type(stat_type)
