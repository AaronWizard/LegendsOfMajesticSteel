class_name Actor
extends Node2D

signal animations_finished

export var tile_size := Vector2(16, 16) setget set_tile_size

var cell: Vector2 setget set_cell
var cell_offset: Vector2 setget set_cell_offset

var controller = null # Is a Controller

onready var stats: Stats = get_node("Stats")

onready var tween: Tween = get_node("Tween")
onready var remote_transform: RemoteTransform2D = get_node(
		"Pivot/RemoteTransform2D")

onready var _pivot: Position2D = get_node("Pivot")
onready var _sprite: Sprite = get_node("Pivot/Sprite")

onready var _anim: AnimationPlayer = get_node("AnimationPlayer")


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


func on_cell(c: Vector2) -> bool:
	return cell == c


func move_step(target_cell: Vector2) -> void:
	assert(cell.distance_squared_to(target_cell) == 1)

	var origin_cell := cell
	set_cell(target_cell)

	set_cell_offset(origin_cell - target_cell)
	# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "cell_offset", cell_offset, Vector2.ZERO,
			_anim.get_animation("move_step").length,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore:return_value_discarded
	tween.start()
	_anim.play("move_step")


func _set_pivot_position() -> void:
	var pivot_cell_pos := cell_offset + (Vector2.ONE / 2.0)
	_pivot.position = pivot_cell_pos * tile_size


func _set_pixel_position() -> void:
	position = cell * tile_size


func _on_Tween_tween_all_completed() -> void:
	emit_signal("animations_finished")
