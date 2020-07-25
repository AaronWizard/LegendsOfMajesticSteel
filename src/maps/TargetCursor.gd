tool
class_name TargetCursor
extends Node2D

export var tile_size: Vector2 = Vector2(1, 1) setget set_tile_size
export var centered: bool = false setget set_centered

onready var _corner_nw := $CornerNW as Node2D
onready var _corner_ne := $CornerNE as Node2D
onready var _corner_se := $CornerSE as Node2D
onready var _corner_sw := $CornerSW as Node2D

func _ready() -> void:
	set_tile_size(tile_size)
	set_centered(centered)


func set_tile_size(new_value: Vector2) -> void:
	tile_size = new_value
	_arrange_corners()


func set_centered(new_value: bool) -> void:
	centered = new_value
	_arrange_corners()


func _arrange_corners() -> void:
	if not _corner_ne:
		return

	if centered:
		var half_size := (tile_size / 2) * Constants.TILE_SIZE

		_corner_ne.position = Vector2( 1, -1) * half_size
		_corner_se.position = Vector2( 1,  1) * half_size
		_corner_sw.position = Vector2(-1,  1) * half_size
		_corner_nw.position = Vector2(-1, -1) * half_size
	else:
		var size := tile_size * Constants.TILE_SIZE

		_corner_ne.position = Vector2(1, 0) * size
		_corner_se.position = Vector2(1, 1) * size
		_corner_sw.position = Vector2(0, 1) * size
		_corner_nw.position = Vector2.ZERO
