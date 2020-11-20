tool
class_name Actor
extends Node2D

signal move_finished

signal animation_trigger(trigger)
signal animation_finished(anim_name)

signal stamina_animation_finished

signal dying
signal died

enum Faction { PLAYER, ENEMY }

class AnimationNames:
	const IDLE := "actor_idle"

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

	const DEATH := {
		Directions.NORTH: "actor_death_north",
		Directions.EAST: "actor_death_east",
		Directions.SOUTH: "actor_death_south",
		Directions.WEST: "actor_death_west"
	}

	const ATTACK_HIT_TRIGGER := "attack_hit"

const _MOVE_TIME := 0.15

export var cell_offset: Vector2 setget set_cell_offset, get_cell_offset

export var character_name := "Actor"

export(Resource) var stat_resource: Resource \
		setget set_stat_resource, get_stat_resource

export(Faction) var faction := Faction.ENEMY

var stats: Stats
var target_visible: bool setget set_target_visible, get_target_visible

onready var cell: Vector2 setget set_cell, get_cell

onready var remote_transform := $Center/Offset/RemoteTransform2D \
		as RemoteTransform2D

onready var battle_stats := $BattleStats as BattleStats

onready var _center := $Center as Position2D
onready var _offset := $Center/Offset as Position2D

onready var _anim := $AnimationPlayer as AnimationPlayer
onready var _tween := $Tween as Tween

onready var _sprite := $Center/Offset/Sprite as Sprite
onready var _blood_splatter := $Center/BloodSplatter \
		as Particles2D

onready var _stamina_bar := $Center/Offset/Sprite/StaminaBar as StaminaBar

onready var _wait_icon := $Center/Offset/WaitIcon as CanvasItem

onready var _target_cursor := $Center/Offset/TargetCursor as TargetCursor


func _ready() -> void:
	_center.position = Constants.TILE_SIZE_V / 2

	var new_cell := \
			position.snapped(Constants.TILE_SIZE_V) / Constants.TILE_SIZE_V
	set_cell(new_cell)

	if stats:
		_stamina_bar.max_stamina = stats.max_stamina


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

	set_cell(target_cell)
	set_cell_offset(-diff)

	if diff.x < 0:
		_sprite.flip_h = true
	elif diff.x > 0:
		_sprite.flip_h = false
	# else change nothing

	_anim.stop(true)
	_sprite.frame = 0

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			get_cell_offset(), Vector2(), _MOVE_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	_anim.play() # Play idle animation again
	emit_signal("move_finished")


func play_death_anim(direction: Vector2) -> void:
	emit_signal("dying")

	var anim_name := AnimationNames.DEATH[direction] as String
	_anim.play(anim_name)
	yield(_anim, "animation_finished")

	emit_signal("died")


func play_anim(anim_name: String) -> void:
	assert(anim_name != AnimationNames.IDLE)

	_anim.play(anim_name)
	yield(_anim, "animation_finished")
	_anim.play("actor_idle")
	emit_signal("animation_finished", anim_name)


func set_stat_resource(new_value: Resource) -> void:
	stats = new_value as Stats
	if stats and _sprite:
		_sprite.texture = stats.texture


func get_stat_resource() -> Resource:
	return stats


func set_target_visible(new_value: bool) -> void:
	_target_cursor.visible = new_value


func get_target_visible() -> bool:
	return _target_cursor.visible


func start_battle() -> void:
	battle_stats.start_battle(stats.max_stamina)
	_stamina_bar.reset()


func _on_BattleStats_stamina_changed(_old_stamina: int, new_stamina: int) \
		-> void:
	if battle_stats.is_alive:
		_stamina_bar.visible = true
		_stamina_bar.animate_change(new_stamina - _old_stamina)


func _on_StaminaBar_animation_finished() -> void:
	_stamina_bar.visible = false
	emit_signal("stamina_animation_finished")


func _on_WaitIconTimer_timeout() -> void:
	_wait_icon.visible = not _wait_icon.visible


func _on_BattleStats_round_started() -> void:
	_wait_icon.visible = false


func _on_BattleStats_turn_taken() -> void:
	if battle_stats.round_finished:
		_wait_icon.visible = true


func _animation_trigger(trigger: String) -> void:
	emit_signal("animation_trigger", trigger)
