class_name TargetCursor
extends Node2D

export var tile_size: Vector2 = Vector2(1, 1) setget set_tile_size

onready var _corner_nw := $CornerNW as Node2D
onready var _corner_ne := $CornerNE as Node2D
onready var _corner_se := $CornerSE as Node2D
onready var _corner_sw := $CornerSW as Node2D

func _ready() -> void:
	set_tile_size(tile_size)


func set_tile_size(new_value: Vector2) -> void:
	tile_size = new_value
	_corner_ne.position.x = tile_size.x * Constants.TILE_SIZE
	_corner_se.position = tile_size * Constants.TILE_SIZE
	_corner_sw.position.y = tile_size.y * Constants.TILE_SIZE
