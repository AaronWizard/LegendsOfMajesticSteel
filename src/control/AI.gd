class_name AI
extends ActorController

onready var _random := RandomNumberGenerator.new()

var _moved := false


func _ready() -> void:
	._ready()
	_random.randomize()
	_moved = false


func get_pauses() -> bool:
	return true


func determine_action(actor: Actor, map: Map, range_data: RangeData, \
		_interface: BattleInterface) -> void:
	var want_move := not _moved
	_moved = want_move

	if want_move:
		var path := _pick_random_path(actor.cell, range_data)
		var action := Move.new(actor, map, path)
		emit_signal("determined_action", action)
	else:
		emit_signal("determined_action", null)


func _pick_random_path(start_cell: Vector2, range_data: RangeData) -> Array:
	var cells := range_data.enterable_cells.duplicate()
	cells.erase(start_cell)
	assert(not (start_cell in cells))

	var index := _random.randi_range(0, cells.size() - 1)
	var target: Vector2 = cells[index]

	var path = range_data.get_walk_path(start_cell, target)
	assert(path.size() > 0)

	return path
