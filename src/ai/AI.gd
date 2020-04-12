class_name AI
extends Controller

onready var _random := RandomNumberGenerator.new()

var _moved := false


func _ready() -> void:
	._ready()
	_random.randomize()
	_moved = false


func get_pauses() -> bool:
	return true


func determine_action(map: Map, _gui: BattleGUI) -> void:
	var want_move := not _moved
	_moved = want_move

	if want_move:
		var path := _pick_random_path()
		var action := Move.new(get_actor(), map, path)
		emit_signal("determined_action", action)
	else:
		emit_signal("determined_action", null)


func _pick_random_path() -> Array:
	var cells := get_battle_stats().enterable_cells.duplicate()
	cells.erase(get_actor().cell)
	assert(not (get_actor().cell in cells))

	var index := _random.randi_range(0, cells.size() - 1)
	var target: Vector2 = cells[index]

	var path = get_battle_stats().get_walk_path(target)
	assert(path.size() > 0)

	return path
