class_name AI
extends ActorController

onready var _random := ExtRandomNumberGenerator.new()

var _moved := false


func _ready() -> void:
	_random.randomize()
	_moved = false


func get_pauses() -> bool:
	return true


func determine_action(actor: Actor, map: Map) -> void:
	var range_data := actor.battle_stats.range_data
	if not range_data.get_valid_skill_source_cells().empty():
		_moved = false

		if not range_data.get_valid_skill_indices_at_cell(
				actor.origin_cell).empty():
			var action := _pick_random_skill(actor, map, range_data)
			emit_signal("determined_action", action)
		else:
			var path := _pick_random_action_path(actor.origin_cell, range_data)
			var action := Move.new(actor, map, path)
			emit_signal("determined_action", action)
	else:
		var want_move := not _moved
		_moved = want_move

		if want_move:
			var path := _pick_random_path(actor.origin_cell, range_data)
			var action := Move.new(actor, map, path)
			emit_signal("determined_action", action)
		else:
			emit_signal("determined_action", null)


func _pick_random_path(start_cell: Vector2, range_data: RangeData) -> Array:
	var cells := range_data.get_move_range()
	cells.erase(start_cell)
	assert(not (start_cell in cells))

	return _random_path(start_cell, range_data, cells)


func _pick_random_action_path(start_cell: Vector2, range_data: RangeData) \
		-> Array:
	var cells := range_data.get_valid_skill_source_cells()
	return _random_path(start_cell, range_data, cells)


func _random_path(start_cell: Vector2, range_data: RangeData, cells: Array) \
		-> Array:
	var target := _random.rand_array_element(cells) as Vector2

	var path = range_data.get_walk_path(start_cell, target)
	assert(path.size() > 0)

	return path


func _pick_random_skill(actor: Actor, map: Map, range_data: RangeData) \
		-> SkillAction:
	var skill_indicies := range_data.get_valid_skill_indices_at_cell(
			actor.origin_cell)
	var skill_index = _random.rand_array_element(skill_indicies) as int

	var skill := actor.stats.skills[skill_index] as Skill
	var targeting_data := \
			range_data.get_targeting_data(actor.origin_cell, skill_index)

	# Pick random target
	var target_cell := \
			_random.rand_array_element(targeting_data.valid_targets) as Vector2

	var result := SkillAction.new(actor, map, skill, target_cell)

	return result
