tool
class_name Actor
extends Node2D

signal animations_finished

enum Faction { PLAYER, ENEMY }

const _MOVE_ANIMS = {
	Directions.NORTH: "actor_move_north",
	Directions.EAST: "actor_move_east",
	Directions.SOUTH: "actor_move_south",
	Directions.WEST: "actor_move_west"
}

export var tile_size := Vector2(16, 16) setget set_tile_size
export var cell_offset: Vector2 setget set_cell_offset, get_cell_offset

export(Faction) var faction := Faction.ENEMY

onready var cell: Vector2 setget set_cell, get_cell

var controller = null # -> Controller

onready var stats := $Stats as Stats
onready var battle_stats := $BattleStats as BattleStats

onready var remote_transform := $Center/Offset/RemoteTransform2D \
		as RemoteTransform2D

onready var _abilities := $Abilities

onready var _center := $Center as Position2D
onready var _offset := $Center/Offset as Position2D

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


func move_step(target_cell: Vector2) -> void:
	assert(get_cell().distance_squared_to(target_cell) == 1)

	var origin_cell := get_cell()
	var diff := target_cell - origin_cell
	var move_anim: String = _MOVE_ANIMS[diff]

	set_cell(target_cell)
	set_cell_offset(-diff)
	_anim.play(move_anim)


func play_anim(anim: String) -> void:
	_anim.play(anim)


func get_abilities() -> Array:
	return _abilities.get_children()


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("animations_finished")
