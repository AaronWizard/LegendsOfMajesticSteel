extends Node

export var start_map_file: PackedScene = null

onready var _map_container := $Map
onready var _map_highlights: MapHighlights = $MapHighlights
onready var _camera: GameCamera = $GameCamera
onready var _turn_manager: TurnManager = $TurnManager
onready var _gui: BattleGUI = $BattleGUI


func _ready() -> void:
	if start_map_file:
		load_map(start_map_file)

	_turn_manager.start(get_current_map(), _gui)


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

	_camera.set_bounds(new_map.get_pixel_rect())


func _on_BattleGUI_mouse_dragged(relative: Vector2) -> void:
	_camera.drag(relative)


func _on_TurnManager_turn_started(actor: Actor) -> void:
	var battle_stats: BattleStats = actor.battle_stats
	_map_highlights.set_moves(battle_stats.move_range)
	_camera.follow_actor(actor)


func _on_TurnManager_action_started(actor: Actor) -> void:
	_camera.follow_actor(actor)


func _on_BattleGUI_ability_pressed(ability: Ability) -> void:
	print(ability.name)
