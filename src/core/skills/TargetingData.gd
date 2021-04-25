class_name TargetingData

var source_cell: Vector2
var target_range: Array
var valid_targets: Array

# Keys are Vector2s, values are Arrays of Vector2s
var _aoe_by_target: Dictionary

# Keys are Vector2s, values are Dictionaries
#	In value dictionaries, keys are Actors and values are ints
var _predicted_damage_by_target: Dictionary

# Keys are Vector2s, values are Dictionaries
# 	In value dictionaries, keys are Actors and values arrays of ConditionEffects
var _predicted_conditions_by_target: Dictionary


func _init(new_source_cell: Vector2, new_target_range: Array,
		new_valid_targets: Array, new_aoe_by_target: Dictionary,
		new_predicted_damages_by_target: Dictionary,
		new_predicted_conditions_by_target: Dictionary) -> void:
	source_cell = new_source_cell
	target_range = new_target_range
	valid_targets = new_valid_targets
	_aoe_by_target = new_aoe_by_target
	_predicted_damage_by_target = new_predicted_damages_by_target
	_predicted_conditions_by_target = new_predicted_conditions_by_target


func get_aoe(target: Vector2) -> Array:
	var result := []
	if _aoe_by_target.has(target):
		result = _aoe_by_target[target] as Array
	return result


func get_predicted_damage(target: Vector2) -> Dictionary:
	var result := {}
	if _predicted_damage_by_target.has(target):
		result = _predicted_damage_by_target[target] as Dictionary
	return result


func get_predicted_conditions(target: Vector2) -> Dictionary:
	var result := {}
	if _predicted_conditions_by_target.has(target):
		result = _predicted_conditions_by_target[target] as Dictionary
	return result
