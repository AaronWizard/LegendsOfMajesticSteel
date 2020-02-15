extends Node

export var start_map_file: PackedScene = null

onready var _map_container := get_node("Map")
onready var _map_highlights: MapHighlights = get_node("MapHighlights")
onready var _camera: GameCamera = get_node("GameCamera")
onready var _turn_manager: TurnManager = get_node("TurnManager")


func _ready() -> void:
	if start_map_file:
		load_map(start_map_file)

	_turn_manager.start(get_current_map())


func get_current_map() -> Map:
	var result: Map = null
	if _map_container.get_child_count() > 0:
		assert(_map_container.get_child_count() == 1)
		result = _map_container.get_child(0) as Map

	return result


func load_map(map_file: PackedScene) -> void:
	var test: Map = map_file.instance()
	assert(test != null)
	_map_container.add_child(test)

	_camera.set_bounds(test.get_pixel_rect())


func _on_TurnManager_followed_actor(actor: Actor) -> void:
	_camera.follow_actor(actor)


func _on_TurnManager_set_movement_range(move_range: Array) -> void:
	_map_highlights.set_move_highlight(move_range)


func _on_TurnManager_cleared_map_highlights() -> void:
	_map_highlights.clear()
