class_name MapHighlights
extends Node

enum Tiles {
	WALK,
	TARGET,
	OTHER_WALK,
	AOE,
	VALID_TARGET
}

var moves_visible: bool setget set_moves_visible, get_moves_visible

var target_cursor_visible: bool setget set_target_cursor_visible, \
		get_target_cursor_visible


var target_cursor_cell: Vector2 setget set_target_cursor_cell, \
		get_target_cursor_cell

onready var _moves := $Moves as TileMap
onready var _targets := $Targets as TileMap
onready var _valid_targets := $ValidTargets as TileMap
onready var _aoe := $AOE as TileMap

onready var _other_range := $OtherRange as TileMap

onready var _target_cursor := $TargetCursor as TargetCursor


func set_moves_visible(value: bool) -> void:
	_moves.visible = value


func get_moves_visible() -> bool:
	return _moves.visible


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


func set_other_range(move_range: Array, target_range: Array, aoe: Array) \
		-> void:
	_set_cells(_other_range, Tiles.AOE, aoe)
	_set_cells(_other_range, Tiles.TARGET, target_range, false)
	_set_cells(_other_range, Tiles.OTHER_WALK, move_range, false)


func clear_other_range() -> void:
	_other_range.clear()


func set_targets(target_range: Array, valid_targets: Array) -> void:
	_set_cells(_targets, Tiles.TARGET, target_range)
	_set_cells(_valid_targets, Tiles.VALID_TARGET, valid_targets)


func clear_targets() -> void:
	_targets.clear()
	_valid_targets.clear()


func set_aoe(cells: Array) -> void:
	_set_cells(_aoe, Tiles.AOE, cells)


func clear_aoe() -> void:
	_aoe.clear()


func _set_cells(tilemap: TileMap, tile: int, cells: Array,
		clear_first := true) -> void:
	var region_set := false
	var start := Vector2()
	var end := Vector2()

	if clear_first:
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
