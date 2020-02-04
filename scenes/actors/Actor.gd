class_name Actor
extends Node2D

export var tile_size := Vector2(16, 16) setget set_tile_size

var cell: Vector2 setget set_cell
var cell_offset: Vector2 setget set_cell_offset

onready var _pivot: Position2D = get_node("Pivot")
onready var _sprite: Sprite = get_node("Pivot/Sprite")

func _ready() -> void:
	var new_cell := position.snapped(tile_size) / tile_size
	set_cell(new_cell)


func set_tile_size(new_value: Vector2) -> void:
	tile_size = new_value
	_set_pivot_position()
	_set_pixel_position()


func set_cell(new_value: Vector2) -> void:
	cell = new_value
	_set_pixel_position()


func set_cell_offset(new_value: Vector2) -> void:
	cell_offset = new_value
	_set_pivot_position()


func _set_pivot_position() -> void:
	var pivot_cell_pos = cell_offset + (Vector2.ONE / 2.0)
	_pivot.position = pivot_cell_pos * tile_size


func _set_pixel_position() -> void:
	position = cell * tile_size


func on_cell(c: Vector2) -> bool:
	return cell == c
