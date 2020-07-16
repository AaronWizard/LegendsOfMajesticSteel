extends Node

export var start_map_file: PackedScene = null

onready var _map_container := $Map
onready var _turn_manager := $TurnManager as TurnManager
onready var _control := $BattleControl as BattleControl

func _ready() -> void:
	if start_map_file:
		load_map(start_map_file)

	_turn_manager.start(get_current_map(), _control)


func get_current_map() -> Map:
	var result: Map = null
	if _map_container.get_child_count() > 0:
		assert(_map_container.get_child_count() == 1)
		result = _map_container.get_child(0) as Map

	return result


func load_map(map_file: PackedScene) -> void:
	var new_map: Map = map_file.instance()
	assert(new_map != null)
	_map_container.add_child(new_map)

	_control.camera.set_bounds(new_map.get_pixel_rect())


# warning-ignore:unused_argument
#func _on_BattleGUI_ability_target_placed(target_cell: Vector2, aoe: Array) \
#		-> void:
#	_map_highlights.target_cursor_visible = true
#	_map_highlights.target_cursor_cell = target_cell
