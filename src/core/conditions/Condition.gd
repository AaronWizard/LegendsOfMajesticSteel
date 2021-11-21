class_name Condition

signal finished

var definition: ConditionDefinition

var rounds_left := 1

# { StatType.Type: StatModifier }
var stat_modifiers: Dictionary setget , get_stat_modifiers

func _init(new_definition: ConditionDefinition) -> void:
	definition = new_definition
	rounds_left = definition.max_rounds


func start_round() -> void:
	if definition.time_type == ConditionDefinition.TimeType.ROUNDS:
		rounds_left -= 1
		if rounds_left <= 0:
			emit_signal("finished")


# { StatType.Type: StatModifier }
func get_stat_modifiers() -> Dictionary:
	return definition.get_grouped_stat_modifiers()
