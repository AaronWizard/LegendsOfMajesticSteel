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


func determine_action(map: Map, range_data: RangeData, \
		_control: BattleControl) -> void:
	var want_move := not _moved
	_moved = want_move

	if want_move:
		var path := _pick_random_path(range_data)
		var action := Move.new(get_actor(), map, path)
		emit_signal("determined_action", action)
	else:
		emit_signal("determined_action", null)


func _pick_random_path(range_data: RangeData) -> Array:
	var cells := range_data.enterable_cells.duplicate()
	cells.erase(get_actor().cell)
	assert(not (get_actor().cell in cells))

	var index := _random.randi_range(0, cells.size() - 1)
	var target: Vector2 = cells[index]

	var path = range_data.get_walk_path(get_actor().cell, target)
	assert(path.size() > 0)

	return path