class_name Actor
extends Node2D

signal animations_finished

enum Faction { PLAYER, ENEMY }

export var tile_size := Vector2(16, 16) setget set_tile_size

export(Faction) var faction := Faction.ENEMY

var cell: Vector2 setget set_cell
var cell_offset: Vector2 setget set_cell_offset

var map setget , get_map # -> Map

var controller = null # -> Controller

onready var stats: Stats = $Stats
onready var battle_stats = $BattleStats # -> BattleStats

onready var tween: Tween = $Tween
onready var remote_transform: RemoteTransform2D = $Pivot/RemoteTransform2D

onready var _pivot: Position2D = $Pivot
onready var _sprite: Sprite = $Pivot/Sprite

onready var _anim: AnimationPlayer = $AnimationPlayer


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


func get_map(): # -> Map
	return owner


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
