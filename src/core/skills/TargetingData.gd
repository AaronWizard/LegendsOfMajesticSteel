class_name TargetingData

enum ThreatRange {
	TARGETS,
	VALID_TARGETS,
	AOE
}


class TargetInfo:
	# Keys are Vector2s, values are value true
	var aoe := {}

	# Keys are Actors and values are ints
	var predicted_damage := {}

	# Keys are Actors and values are arrays of StatModifiers
	var predicted_stat_mods := {}

	func add(other_info: TargetInfo) -> void:
		for c in other_info.aoe:
			var cell := c as Vector2
			aoe[cell] = true

		for a in other_info.predicted_damage:
			var actor := a as Actor
			var damage := other_info.predicted_damage[actor] as int
			if not predicted_damage.has(actor):
				predicted_damage[actor] = 0
			predicted_damage[actor] += damage

		for a in other_info.predicted_stat_mods:
			var actor := a as Actor
			var stat_mods := other_info.predicted_stat_mods[actor] as Array
			if not predicted_stat_mods.has(actor):
				predicted_stat_mods[actor] = []
			(predicted_stat_mods[actor] as Array).append_array(stat_mods)


var source_cell: Vector2
var target_range: Array
var valid_targets: Array

# Keys are Vector2s, values are TargetInfos
var _infos_by_target: Dictionary


func _init(new_source_cell: Vector2, new_target_range: Array,
		new_valid_targets: Array, new_infos_by_target: Dictionary) -> void:
	source_cell = new_source_cell
	target_range = new_target_range
	valid_targets = new_valid_targets
	_infos_by_target = new_infos_by_target


func get_target_info(target: Vector2) -> TargetInfo:
	var result: TargetInfo = null
	if _infos_by_target.has(target):
		result = _infos_by_target[target] as TargetInfo
	return result


func get_aoe(target: Vector2) -> Array:
	var result := []
	if _infos_by_target.has(target):
		var target_info := _infos_by_target[target] as TargetInfo
		result = target_info.aoe.keys()
	return result


func get_predicted_damage(target: Vector2) -> Dictionary:
	var result := {}
	if _infos_by_target.has(target):
		var target_info := _infos_by_target[target] as TargetInfo
		result = target_info.predicted_damage
	return result


func get_predicted_stat_mods(target: Vector2) -> Dictionary:
	var result := {}
	if _infos_by_target.has(target):
		var target_info := _infos_by_target[target] as TargetInfo
		result = target_info.predicted_stat_mods
	return result
