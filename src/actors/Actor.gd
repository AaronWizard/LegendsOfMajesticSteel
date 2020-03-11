tool
class_name Actor
extends Node2D

signal animations_finished

enum Faction { PLAYER, ENEMY }

const _MOVE_STEP_ANIM := "actor_move_step"

export var tile_size := Vector2(16, 16) setget set_tile_size

export(Faction) var faction := Faction.ENEMY

onready var cell: Vector2 setget set_cell, get_cell
var cell_offset: Vector2 setget set_cell_offset

var map setget , get_map # -> Map

var controller = null # -> Controller

onready var stats := $Stats as Stats
onready var battle_stats = $BattleStats # -> BattleStats

onready var remote_transform := $Pivot/RemoteTransform2D as RemoteTransform2D

onready var _abilities := $Abilities

onready var _pivot := $Pivot as Position2D

onready var _tween := $Tween as Tween
onready var _anim := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	var new_cell := position.snapped(tile_size) / tile_size
	set_tile_size(tile_size)
	set_cell(new_cell)


func _draw() -> void:
	if Engine.editor_hint:
		var rect = Rect2(Vector2.ZERO, tile_size)
		draw_rect(rect, Color.magenta, false)


func set_tile_size(new_value: Vector2) -> void:
	var old_cell = get_cell() # Cell based on position and old tile_size
	tile_size = new_value
	set_cell(old_cell)
	_set_pivot_position()
	update()


func set_cell(new_value: Vector2) -> void:
	position = new_value * tile_size


func get_cell() -> Vector2:
	return position / tile_size


func set_cell_offset(new_value: Vector2) -> void:
	cell_offset = new_value
	_set_pivot_position()


func on_cell(c: Vector2) -> bool:
	return get_cell() == c


func get_map(): # -> Map
	return owner


func move_step(target_cell: Vector2) -> void:
	assert(get_cell().distance_squared_to(target_cell) == 1)

	var origin_cell := get_cell()
	set_cell(target_cell)

	set_cell_offset(origin_cell - target_cell)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(self, "cell_offset", cell_offset, Vector2.ZERO,
			_anim.get_animation(_MOVE_STEP_ANIM).length,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore:return_value_discarded
	_tween.start()
	_anim.play(_MOVE_STEP_ANIM)


func get_abilities() -> Array:
	return _abilities.get_children()


func _set_pivot_position() -> void:
	if _pivot:
		var pivot_cell_pos := cell_offset + (Vector2.ONE / 2.0)
		_pivot.position = pivot_cell_pos * tile_size


func _on_Tween_tween_all_completed() -> void:
	emit_signal("animations_finished")
