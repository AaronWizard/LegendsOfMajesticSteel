class_name Actor
extends Node2D

export var tile_size := Vector2(16, 16) setget set_tile_size
var cell_pos: Vector2 setget set_cell_pos


func _ready() -> void:
	var cell := position.snapped(tile_size) / tile_size
	set_cell_pos(cell)
	print(cell_pos)


func set_tile_size(new_value: Vector2) -> void:
	tile_size = new_value
	_set_pixel_position()


func set_cell_pos(new_value: Vector2) -> void:
	cell_pos = new_value
	_set_pixel_position()


func _set_pixel_position() -> void:
	position = cell_pos * tile_size


func on_cell(cell: Vector2) -> bool:
	return cell_pos == cell


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var map := get_parent() as TileMap
		if map:
			var click_pos := map.get_local_mouse_position()
			var click_cell := map.world_to_map(click_pos)
			set_cell_pos(click_cell)
