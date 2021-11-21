class_name ConditionDefinition, "res://assets/editor/condition_definition.png"
extends Resource

enum TimeType {
	ROUNDS,
	INDEFINITE
}

export(TimeType) var time_type: int = TimeType.ROUNDS
export var max_rounds := 1

export(Array, Resource) var stat_modifiers := []


# { StatType.Type: StatModifier }
func get_grouped_stat_modifiers() -> Dictionary:
	var result := {}

	for m in stat_modifiers:
		var modifier := m as StatModifier
		if result.has(modifier.type):
			var old_modifier := result[modifier.type] as StatModifier

			var new_modifier := StatModifier.new()
			new_modifier.value = old_modifier.value + modifier.value

			result[modifier.type] = new_modifier
		else:
			result[modifier.type] = modifier

	return result
