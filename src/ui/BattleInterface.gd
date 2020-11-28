class_name BattleInterface
extends Node

enum State {
	WAITING,
	PLAYER_TURN_MOVE,
	PLAYER_TURN_TARGET,
	PLAYER_TURN_TARGET_CONFIRM
}

var current_map: Map = null setget set_current_map
var current_actor: Actor = null setget set_current_actor

var player: Player = null setget set_player

onready var map_highlights := $MapHighlights as MapHighlights
onready var camera := $GameCamera as GameCamera
onready var mouse := $MouseControl as MouseControl
onready var gui := $BattleGUI as BattleGUI

var _range_data: RangeData = null
var _ability_target: Vector2

var _state: int = State.WAITING


func set_current_map(value: Map) -> void:
	current_map = value
	camera.set_bounds(current_map.get_pixel_rect())


func set_current_actor(value: Actor) -> void:
	current_actor = value
	gui.current_actor = value

	if current_actor:
		_range_data = RangeData.new(current_actor, current_map)
	else:
		_range_data = null


func set_player(new_value: Player) -> void:
	player = new_value
	if player != null:
		_state = State.PLAYER_TURN_MOVE
		gui.buttons_visible = true
		mouse.dragging_enabled = true
	else:
		_state = State.WAITING
		gui.buttons_visible = false
		mouse.dragging_enabled = false


func _on_MouseControl_click(_position: Vector2) -> void:
	var target_cell := current_map.get_mouse_cell()
	match _state:
		State.PLAYER_TURN_MOVE:
			_player_move(target_cell)
		State.PLAYER_TURN_TARGET:
			_player_target(target_cell)
		State.PLAYER_TURN_TARGET_CONFIRM:
			_player_target_confirm(target_cell)


func _on_MouseControl_drag(relative: Vector2) -> void:
	camera.drag(relative)


func _on_BattleGUI_ability_selected(ability_index: int) -> void:
	var targeting_data := _range_data.get_targeting_data(
			current_actor.cell, ability_index)
	map_highlights.set_targets(targeting_data.target_range)
	map_highlights.moves_visible = false

	_state = State.PLAYER_TURN_TARGET


func _on_BattleGUI_ability_cleared() -> void:
	map_highlights.target_cursor_visible = false
	map_highlights.set_targets([])
	map_highlights.moves_visible = true

	_state = State.PLAYER_TURN_MOVE


func _on_BattleGUI_wait_started() -> void:
	_player_action(null)


func _player_move(target_cell: Vector2) -> void:
	var path := _range_data.get_walk_path(current_actor.cell, target_cell)
	if path.size() > 0:
		var action := Move.new(current_actor, current_map, path)
		action.allow_cancel(mouse)
		_player_action(action)


func _player_target(target_cell: Vector2) -> void:
	var ability_index := gui.current_ability_index
	var targeting_data := _range_data.get_targeting_data(
			current_actor.cell, ability_index)

	if target_cell in targeting_data.valid_targets:
		map_highlights.target_cursor_visible = true
		map_highlights.target_cursor_cell = target_cell
		_ability_target = target_cell

		_state = State.PLAYER_TURN_TARGET_CONFIRM


func _player_target_confirm(target_cell: Vector2) -> void:
	if _ability_target == target_cell:
		var ability := current_actor.stats.abilities[ \
				gui.current_ability_index] as Ability
		var action := AbilityAction.new( \
				current_actor, current_map, ability, target_cell)
		gui.current_ability_index = -1
		_player_action(action)


func _player_action(action: Action) -> void:
	player.do_action(action)
	player = null
	_state = State.WAITING
