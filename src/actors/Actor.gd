tool
class_name Actor
extends Node2D

signal move_finished

signal animation_trigger(trigger)
signal animation_finished(anim_name)

signal stamina_animation_finished

signal died(actor)

enum Faction { PLAYER, ENEMY }

class AnimationNames:
	const IDLE := "actor_idle"

	const MOVE := {
		Directions.NORTH: "actor_move_north",
		Directions.EAST: "actor_move_east",
		Directions.SOUTH: "actor_move_south",
		Directions.WEST: "actor_move_west"
	}

	const ATTACK := {
		Directions.NORTH: "actor_attack_north",
		Directions.EAST: "actor_attack_east",
		Directions.SOUTH: "actor_attack_south",
		Directions.WEST: "actor_attack_west"
	}

	const REACT := {
		Directions.NORTH: "actor_attack_react_north",
		Directions.EAST: "actor_attack_react_east",
		Directions.SOUTH: "actor_attack_react_south",
		Directions.WEST: "actor_attack_react_west"
	}

	const ATTACK_HIT_TRIGGER := "attack_hit"

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

onready var _stamina_bar := $Center/Offset/Sprite/StaminaBar as StaminaBar

onready var _anim := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	_center.position = Constants.TILE_SIZE_V / 2

	var new_cell := \
			position.snapped(Constants.TILE_SIZE_V) / Constants.TILE_SIZE_V
	set_cell(new_cell)


func _draw() -> void:
	if Engine.editor_hint:
		var rect := Rect2(Vector2.ZERO, Constants.TILE_SIZE_V)
		draw_rect(rect, Color.magenta, false)


func set_cell(new_value: Vector2) -> void:
	position = new_value * Constants.TILE_SIZE_V


func get_cell() -> Vector2:
	return position / Constants.TILE_SIZE_V


func set_cell_offset(new_value: Vector2) -> void:
	if _offset:
		_offset.position = new_value * Constants.TILE_SIZE_V


func get_cell_offset() -> Vector2:
	var result := Vector2.ZERO
	if _offset:
		result = _offset.position / Constants.TILE_SIZE_V
	return result


func on_cell(c: Vector2) -> bool:
	return get_cell() == c


func move_step(target_cell: Vector2) -> void:
	assert(get_cell().distance_squared_to(target_cell) == 1)

	var origin_cell := get_cell()
	var diff := target_cell - origin_cell
	var move_anim: String = AnimationNames.MOVE[diff]

	set_cell(target_cell)
	set_cell_offset(-diff)

	_anim.play(move_anim)
	yield(_anim, "animation_finished")
	_anim.play(AnimationNames.IDLE)

	emit_signal("move_finished")


func play_anim(anim_name: String) -> void:
	assert(anim_name != AnimationNames.IDLE)

	_anim.play(anim_name)
	yield(_anim, "animation_finished")
	_anim.play("actor_idle")
	emit_signal("animation_finished", anim_name)


func get_abilities() -> Array:
	return _abilities.get_children()


func _on_BattleStats_died() -> void:
	emit_signal("died", self)


func _on_BattleStats_stamina_changed(_old_stamina: int, new_stamina: int) \
		-> void:
	if battle_stats.is_alive:
		_stamina_bar.visible = true
		_stamina_bar.animate_change(new_stamina - _old_stamina)


func _on_StaminaBar_animation_finished() -> void:
	_stamina_bar.visible = false
	emit_signal("stamina_animation_finished")


func _animation_trigger(trigger: String) -> void:
	emit_signal("animation_trigger", trigger)
