class_name MapHighlights
extends Node

enum Tiles {
	WALK,
	TARGET,
	AOE,
}

onready var _moves: TileMap = $Moves
onready var _targets: TileMap = $Targets
onready var _aoe: TileMap = $AOE


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
