class_name AI
extends ActorController

onready var _random := ExtRandomNumberGenerator.new()

var _moved := false


func _ready() -> void:
	_random.randomize()
	_moved = false


func get_pauses() -> bool:
	return true


func determine_action(actor: Actor, map: Map, range_data: RangeData, \
		_interface: BattleInterface) -> void:
	if not range_data.ability_source_cells.empty():
		_moved = false

		if range_data.ability_source_cells.has(actor.cell):
			var action := _pick_random_ability(actor, map, range_data)
			emit_signal("determined_action", action)
		else:
			var path := _pick_random_action_path(actor.cell, range_data)
			var action := Move.new(actor, map, path)
			emit_signal("determined_action", action)
	else:
		var want_move := not _moved
		_moved = want_move

		if want_move:
			var path := _pick_random_path(actor.cell, range_data)
			var action := Move.new(actor, map, path)
			emit_signal("determined_action", action)
		else:
			emit_signal("determined_action", null)


func _pick_random_path(start_cell: Vector2, range_data: RangeData) -> Array:
	var cells := range_data.move_range.keys()
	cells.erase(start_cell)
	assert(not (start_cell in cells))

	return _random_path(start_cell, range_data, cells)


func _pick_random_action_path(start_cell: Vector2, range_data: RangeData) \
		-> Array:
	var cells := range_data.ability_source_cells.keys()
	return _random_path(start_cell, range_data, cells)


func _random_path(start_cell: Vector2, range_data: RangeData, cells: Array) \
		-> Array:
	var target := _random.rand_array_element(cells) as Vector2

	var path = range_data.get_walk_path(start_cell, target)
	assert(path.size() > 0)

	return path


func _pick_random_ability(actor: Actor, map: Map, range_data: RangeData) \
		-> AbilityAction:
	var ability_indicies := range_data.get_abilities_at_cell(actor.cell)
	var ability_index = _random.rand_array_element(ability_indicies) as int

	var ability := actor.stats.abilities[ability_index] as Ability
	var targeting_data := \
			range_data.get_targeting_data(actor.cell, ability_index)

	# Pick random target
	var target_cell := \
			_random.rand_array_element(targeting_data.valid_targets) as Vector2

	var result := AbilityAction.new(actor, map, ability, target_cell)

	return result
