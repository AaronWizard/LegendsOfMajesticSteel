class_name ConditionEffect, "res://assets/editor/condition_effect.png"
extends Resource

enum TimeType {
	ROUNDS,
	INDEFINITE
}

export(TimeType) var time_type: int = TimeType.ROUNDS
export var max_rounds := 1

export(Array, Resource) var stat_modifiers := []


func get_modifiers_by_type(stat_type: int) -> Array:
	var result := []

	for m in stat_modifiers:
		var modifier := m as StatModifier
		if modifier.type == stat_type:
			result.append(modifier)

	return result
