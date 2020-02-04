extends Node

export(PackedScene) var start_map_file = null

onready var _map_container := get_node("Map")
onready var _turn_manager := TurnManager.new()


func _ready() -> void:
	if start_map_file:
		load_map(start_map_file)

	_turn_manager.actors = get_current_map().get_actors()
	_turn_manager.start()

func get_current_map() -> Map:
	var result: Map = null
	if _map_container.get_child_count() > 0:
		result = _map_container.get_child(0) as Map

	return result


func load_map(map_file: PackedScene) -> void:
	var test := map_file.instance()
	_map_container.add_child(test)