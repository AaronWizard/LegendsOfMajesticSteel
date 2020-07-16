class_name BattleControl
extends Node

var current_map: Map = null
var current_actor: Actor = null setget set_current_actor

onready var map_highlights := $MapHighlights as MapHighlights
onready var camera := $GameCamera as GameCamera
onready var mouse := $MouseControl as MouseControl
onready var gui := $BattleGUI as BattleGUI


func set_current_actor(value: Actor) -> void:
	current_actor = value
	gui.current_actor = value


func set_target(target_cell: Vector2) -> void:
	map_highlights.target_cursor_visible = true
	map_highlights.target_cursor_cell = target_cell


func _on_MouseControl_drag(relative: Vector2) -> void:
	camera.drag(relative)


func _on_BattleGUI_ability_selected(ability: Ability) -> void:
	var ability_range := ability.get_targetting_data(current_actor, current_map)
	map_highlights.set_targets(ability_range.target_range)
	map_highlights.moves_visible = false


func _on_BattleGUI_ability_cleared() -> void:
	map_highlights.target_cursor_visible = false
	map_highlights.set_targets([])
	map_highlights.moves_visible = true
