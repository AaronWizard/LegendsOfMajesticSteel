class_name ConditionEffect
extends Resource

export var name := "Condition"
export var icon: Texture

export(Array, Resource) var stat_modifiers := []


func get_modifiers_by_type(stat_type: int) -> Array:
	var result := []

	for m in stat_modifiers:
		var modifier := m as StatModifier
		if modifier.type == stat_type:
			result.append(modifier)

	return result
