class_name TargetingData

var source_cell: Vector2
var target_range: Array
var valid_targets: Array

var _aoe_by_target: Dictionary

func _init(new_source_cell: Vector2, new_target_range: Array,
		new_valid_targets: Array, new_aoe_by_target: Dictionary) -> void:
	source_cell = new_source_cell
	target_range = new_target_range
	valid_targets = new_valid_targets
	_aoe_by_target = new_aoe_by_target


func get_aoe(target: Vector2) -> Array:
	var result := []
	if _aoe_by_target.has(target):
		result = _aoe_by_target[target] as Array
	return result
