tool
class_name TileObject
extends Node2D


# The top-left corner of the tile object
export var origin_cell := Vector2.ZERO setget set_origin_cell, get_origin_cell

# Offset is in cells
export var cell_offset := Vector2.ZERO setget set_cell_offset, get_cell_offset

# Rect size is in cells
export var rect_size := Vector2.ONE setget set_rect_size

var center_cell: Vector2 setget , get_center_cell
var cell_rect: Rect2 setget , get_cell_rect

onready var _center := $Center as Position2D
onready var _offset := $Center/Offset as Position2D

var _covered_cells := {}


func _ready() -> void:
	set_rect_size(rect_size)

	var new_cell := \
			position.snapped(Constants.TILE_SIZE_V) / Constants.TILE_SIZE_V
	set_origin_cell(new_cell)


func _draw() -> void:
	if Engine.editor_hint:
		var rect := Rect2(Vector2.ZERO, Constants.TILE_SIZE_V * rect_size)
		draw_rect(rect, Color.magenta, false)


func set_origin_cell(value: Vector2) -> void:
	position = value * Constants.TILE_SIZE_V


func get_origin_cell() -> Vector2:
	return position / Constants.TILE_SIZE_V


func set_cell_offset(value: Vector2) -> void:
	if _offset:
		_offset.position = value * Constants.TILE_SIZE_V


func get_cell_offset() -> Vector2:
	var result := Vector2.ZERO
	if _offset:
		result = _offset.position / Constants.TILE_SIZE_V
	return result


func set_rect_size(value: Vector2) -> void:
	assert(value.x > 0)
	assert(value.y > 0)

	rect_size = value

	_covered_cells.clear()
	for x in range(rect_size.x):
		for y in range(rect_size.y):
			var covered := Vector2(x, y)
			_covered_cells[covered] = true

	if _center:
		_center.position = rect_size * (Constants.TILE_SIZE_V / 2)

	update()


func get_center_cell() -> Vector2:
	var result := get_origin_cell()
	if _center:
		result += _center.position / Constants.TILE_SIZE_V
	return result


func get_cell_rect() -> Rect2:
	return get_cell_rect_at_cell(get_origin_cell())


func get_cell_rect_at_cell(cell: Vector2) -> Rect2:
	return Rect2(cell, rect_size)


func on_cell(cell: Vector2) -> bool:
	var local_cell := cell - get_origin_cell()
	return _covered_cells.has(local_cell)


func get_covered_cells() -> Array:
	return get_covered_cells_at_cell(get_origin_cell())


func get_covered_cells_at_cell(cell: Vector2) -> Array:
	var result := []
	for c in _covered_cells.keys():
		var covered := c as Vector2
		var real_cell := covered + cell
		result.append(real_cell)
	return result
