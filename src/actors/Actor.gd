tool
class_name Actor
extends Node2D

signal animations_finished

enum Faction { PLAYER, ENEMY }

const _MOVE_STEP_ANIM := "actor_move_step"

export var tile_size := Vector2(16, 16) setget set_tile_size

export(Faction) var faction := Faction.ENEMY

onready var cell: Vector2 setget set_cell, get_cell
var cell_offset: Vector2 setget set_cell_offset, get_cell_offset

var map setget , get_map # -> Map

var controller = null # -> Controller

onready var stats := $Stats as Stats
onready var battle_stats = $BattleStats # -> BattleStats

onready var remote_transform := $Center/Offset/RemoteTransform2D \
		as RemoteTransform2D

onready var _abilities := $Abilities

onready var _center := $Center as Position2D
onready var _offset := $Center/Offset as Position2D

onready var _tween := $Tween as Tween
onready var _anim := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	var new_cell := position.snapped(tile_size) / tile_size
	set_tile_size(tile_size)
	set_cell(new_cell)


func _draw() -> void:
	if Engine.editor_hint:
		var rect := Rect2(Vector2.ZERO, tile_size)
		draw_rect(rect, Color.magenta, false)


func set_tile_size(new_value: Vector2) -> void:
	# Cell and cell offset based on old tile_size
	var old_cell := get_cell()
	var old_cell_offset := get_cell_offset()

	tile_size = new_value
	if _center:
		_center.position = tile_size / 2

	set_cell(old_cell)
	set_cell_offset(old_cell_offset)

	update()


func set_cell(new_value: Vector2) -> void:
	position = new_value * tile_size


func get_cell() -> Vector2:
	return position / tile_size


func set_cell_offset(new_value: Vector2) -> void:
	if _offset:
		_offset.position = new_value * tile_size


func get_cell_offset() -> Vector2:
	var result := Vector2.ZERO
	if _offset:
		result = _offset.position / tile_size
	return result


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
	_tween.interpolate_property(
			self, "cell_offset", get_cell_offset(), Vector2.ZERO,
			_anim.get_animation(_MOVE_STEP_ANIM).length,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore:return_value_discarded
	_tween.start()
	_anim.play(_MOVE_STEP_ANIM)


func get_abilities() -> Array:
	return _abilities.get_children()


func _on_Tween_tween_all_completed() -> void:
	emit_signal("animations_finished")
