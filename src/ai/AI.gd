class_name AI
extends Controller

onready var _random := RandomNumberGenerator.new()


func _ready() -> void:
	._ready()
	_random.randomize()


func get_pauses() -> bool:
	return true


func determine_action(_gui: BattleGUI) -> void:
	var path = _pick_random_path()
	var action := MoveAction.new(get_actor(), get_map(), path)
	get_battle_stats().finished = true
	emit_signal("determined_action", action)


func _pick_random_path() -> Array:
	var cells := get_battle_stats().enterable_cells.duplicate()
	cells.erase(get_actor().cell)
	assert(not (get_actor().cell in cells))

	var index := _random.randi_range(0, cells.size() - 1)
	var target: Vector2 = cells[index]

	var path = get_battle_stats().get_walk_path(target)
	assert(path.size() > 0)

	return path
