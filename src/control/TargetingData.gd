class_name TargetingData

var source_cell: Vector2
var target_range: Array
var valid_targets: Array

func _init(new_source_cell: Vector2, new_target_range: Array,
		new_valid_targets: Array) -> void:
	source_cell = new_source_cell
	target_range = new_target_range
	valid_targets = new_valid_targets
