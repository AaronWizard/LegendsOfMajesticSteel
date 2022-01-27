class_name Game
extends Node

export var start_map_file: PackedScene = null

const _MUSIC := preload("res://assets/music/battle01.mp3")

var map: Map setget , get_map
var current_actor: Actor setget , get_current_actor

var interface: BattleInterface setget , get_interface

onready var actor_ai := $AIActorTurn as AIActorTurn

var _map: Map
var _current_actor: Actor

var _walk_ranges := {} # Keys are actors, values are WalkRanges

# Keys are actors, values are Dictionaries whose keys are the enum
# TargetingData.ThreatRange
var _threat_ranges := {}

onready var _screen_transition := $CanvasLayer/ScreenTransition \
		as ScreenTransition

onready var _map_container := $Map
onready var _interface := $BattleInterface as BattleInterface

onready var _state_machine := $StateMachine as StateMachine
onready var _next_turn_state := $StateMachine/NextTurnState as State


func _ready() -> void:
	var seed_number := OS.get_unix_time()
	seed(seed_number)
	if OS.is_debug_build():
		print("Random seed: %d" % seed_number)

	_load_map(start_map_file)
	_position_camera_start()
	_start_battle()


func get_map() -> Map:
	return _map


func get_current_actor() -> Actor:
	return _current_actor


func get_interface() -> BattleInterface:
	return _interface


func refresh_ranges(turn_start: bool) -> void:
	_threat_ranges.clear()

	if turn_start:
		_walk_ranges.clear()
	else:
		for a in _walk_ranges.keys():
			var actor := a as Actor
			if actor != _current_actor:
				# warning-ignore:return_value_discarded
				_walk_ranges.erase(actor)


func get_active_actors(faction: int) -> Array:
	var result := []

	for a in _map.get_actors_by_faction(faction):
		var actor := a as Actor
		if not actor.round_finished:
			result.append(actor)

	return result


func get_current_walk_range() -> WalkRange:
	return get_walk_range(_current_actor)


func get_walk_range(actor: Actor) -> WalkRange:
	if not _walk_ranges.has(actor):
		_walk_ranges[actor] = WalkRangeFactory.create_walk_range(actor, _map)
	return _walk_ranges[actor]


func get_threat_range(actor: Actor) -> Dictionary:
	if not _threat_ranges.has(actor):
		_threat_ranges[actor] = _get_threat_range(actor)
	return _threat_ranges[actor]


func player_won() -> bool:
	var result := false
	var enemies := _map.get_actors_by_faction(Actor.Faction.ENEMY)
	result = enemies.size() == 0
	return result


func player_lost() -> bool:
	var result := false
	var players := _map.get_actors_by_faction(Actor.Faction.PLAYER)
	result = players.size() == 0
	return result


func start_turn() -> void:
	if _current_actor:
		_current_actor.round_finished = true
		_clear_turn_data()
		_interface.gui.turn_panel.next_turn()

	_current_actor = _map.turn_queue.next_actor()
	assert(_current_actor.stats.is_alive)

	refresh_ranges(true)

	_interface.set_current_actor(
		_current_actor, get_current_walk_range().get_visible_move_range())


func _clear_turn_data() -> void:
	_current_actor = null
	_walk_ranges.clear()
	_threat_ranges.clear()


func _load_map(map_file: PackedScene) -> void:
	_clear_turn_data()

	if _map != null:
		_map.turn_queue.disconnect("actor_removed", self, "_on_actor_removed")
		_map_container.remove_child(_map)
		_map.queue_free()
		_map = null
		_interface.current_map = null
		assert(_map_container.get_child_count() == 0)

	var new_map := map_file.instance() as Map
	assert(new_map != null)

	_map_container.add_child(new_map)
	_map = new_map
	_interface.current_map = new_map
	# warning-ignore:return_value_discarded
	_map.turn_queue.connect("actor_removed", self, "_on_actor_removed")


func _position_camera_start() -> void:
	var player_actors := get_map().get_actors_by_faction(Actor.Faction.PLAYER)

	var cells := []
	for a in player_actors:
		var actor := a as Actor
		cells.append(actor.center_cell - Vector2(0.5, 0.5))

	var center_cell := TileGeometry.center_cell_of_cells(cells)
	center_cell *= Constants.TILE_SIZE
	get_interface().camera.position = center_cell


func _start_battle() -> void:
	for a in _map.get_actors():
		var actor := a as Actor
		actor.start_battle()

	actor_ai.reset()

	_interface.gui.turn_panel.set_actors(_map.get_actors())

	_screen_transition.fade_in()
	yield(_screen_transition, "faded_in")
	yield(get_tree().create_timer(0.1), "timeout")

	BackgroundMusic.start(_MUSIC)

	_state_machine.change_state(_next_turn_state)


func _get_threat_range(actor: Actor) -> Dictionary:
	var walk_range := get_walk_range(actor)
	var skills := actor.get_next_turn_skills()

	var all_targets := {}
	var all_valid_targets := {}
	var all_aoe := {}

	for c in walk_range.get_move_range():
		var cell := c as Vector2
		for s in skills:
			var skill := s as Skill
			var targetting_data := skill.get_targeting_data(
					cell, actor, get_map())
			for t in targetting_data.target_range:
				var target_cell := t as Vector2
				all_targets[target_cell] = true
			for t in targetting_data.valid_targets:
				var target_cell := t as Vector2
				all_valid_targets[target_cell] = true

				var skill_aoe := targetting_data.get_aoe(target_cell)
				for e in skill_aoe:
					var aoe_cell := e as Vector2
					all_aoe[aoe_cell] = true

	return {
		TargetingData.ThreatRange.TARGETS: all_targets.keys(),
		TargetingData.ThreatRange.VALID_TARGETS: all_valid_targets.keys(),
		TargetingData.ThreatRange.AOE: all_aoe.keys()
	}


func _on_actor_removed(_actor: Actor, turn_index: int) -> void:
	_interface.gui.turn_panel.remove_icon(turn_index)
