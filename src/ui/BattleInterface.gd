class_name BattleInterface
extends Node

var current_map: Map = null setget set_current_map

onready var map_highlights := $MapHighlights as MapHighlights
onready var camera := $GameCamera as GameCamera
onready var mouse := $MouseControl as MouseControl
onready var gui := $BattleGUI as BattleGUI


func set_current_map(value: Map) -> void:
	current_map = value
	camera.set_bounds(current_map.get_pixel_rect())


func set_actor(actor: Actor) -> void:
	map_highlights.moves_visible = true
	map_highlights.set_moves(
			actor.battle_stats.range_data.get_visible_move_range())
	camera.follow_actor(actor)
	gui.current_actor = actor


func clear_actor() -> void:
	map_highlights.moves_visible = false
	map_highlights.clear_moves()
	gui.current_actor = null


func action_starting(action: Action) -> void:
	gui.buttons_visible = false
	mouse.dragging_enabled = false

	camera.follow_actor(action.actor)
	map_highlights.moves_visible = action.show_map_highlights()


func _on_MouseControl_drag(relative: Vector2) -> void:
	camera.drag(relative)
