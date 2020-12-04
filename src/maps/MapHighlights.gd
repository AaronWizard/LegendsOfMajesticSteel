class_name MapHighlights
extends Node

enum Tiles {
	WALK,
	TARGET,
	OTHER_WALK
}

var moves_visible: bool setget set_moves_visible, get_moves_visible
var targets_visible: bool setget set_targets_visible, get_targets_visible

var target_cursor_visible: bool setget set_target_cursor_visible, \
		get_target_cursor_visible


var target_cursor_cell: Vector2 setget set_target_cursor_cell, \
		get_target_cursor_cell

onready var _moves := $Moves as TileMap
onready var _other_moves := $OtherMoves as TileMap

onready var _targets := $Targets as TileMap
#onready var _aoe := $AOE as TileMap
onready var _target_cursor := $TargetCursor as TargetCursor


func set_moves_visible(value: bool) -> void:
	_moves.visible = value
	_other_moves.visible = value


func get_moves_visible() -> bool:
	return _moves.visible


func set_targets_visible(value: bool) -> void:
	_targets.visible = value
#	_aoe.visible = value


func get_targets_visible() -> bool:
	return _targets.visible


func set_target_cursor_visible(value: bool) -> void:
	_target_cursor.visible = value


func get_target_cursor_visible() -> bool:
	return _target_cursor.visible


func set_target_cursor_cell(value: Vector2) -> void:
	_target_cursor.position = value * _moves.cell_size


func get_target_cursor_cell() -> Vector2:
	return _target_cursor.position / _moves.cell_size


func set_moves(cells: Array) -> void:
	_set_cells(_moves, Tiles.WALK, cells)


func clear_moves() -> void:
	_moves.clear()


func set_other_moves(cells: Array) -> void:
	_set_cells(_other_moves, Tiles.OTHER_WALK, cells)


func clear_other_moves() -> void:
	_other_moves.clear()


func set_targets(cells: Array) -> void:
	_set_cells(_targets, Tiles.TARGET, cells)


func clear_targets() -> void:
	_targets.clear()


#func set_aoe(cells: Array) -> void:
#	_set_cells(_aoe, Tiles.AOE, cells)


func _set_cells(tilemap: TileMap, tile: int, cells: Array) -> void:
	var region_set := false
	var start := Vector2()
	var end := Vector2()

	tilemap.clear()

	for c in cells:
		var cell: Vector2 = c
		tilemap.set_cellv(cell, tile)

		if not region_set:
			region_set = true
			start = cell
			end = cell
		else:
			start.x = min(start.x, cell.x)
			start.y = min(start.y, cell.y)

			end.x = max(end.x, cell.x)
			end.y = max(end.y, cell.y)

	tilemap.update_bitmask_region(start, end)
