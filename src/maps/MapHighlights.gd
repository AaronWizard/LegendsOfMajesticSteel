class_name MapHighlights
extends Node

enum Tiles {
	WALK,
	TARGET,
	AOE,
}

var moves_visible: bool setget set_moves_visible, get_moves_visible
var targets_visible: bool setget set_targets_visible, get_targets_visible

onready var _moves: TileMap = $Moves
onready var _targets: TileMap = $Targets
onready var _aoe: TileMap = $AOE


func set_moves_visible(value: bool) -> void:
	_moves.visible = value


func get_moves_visible() -> bool:
	return _moves.visible


func set_targets_visible(value: bool) -> void:
	_targets.visible = value
	_aoe.visible = value


func get_targets_visible() -> bool:
	return _targets.visible


func set_moves(cells: Array) -> void:
	_set_cells(_moves, Tiles.WALK, cells)


func set_targets(cells: Array) -> void:
	_set_cells(_targets, Tiles.TARGET, cells)


func set_aoe(cells: Array) -> void:
	_set_cells(_aoe, Tiles.AOE, cells)


func _set_cells(tilemap: TileMap, tile: int, cells: Array) -> void:
	tilemap.clear()
	for c in cells:
		var cell: Vector2 = c
		tilemap.set_cellv(cell, tile)
