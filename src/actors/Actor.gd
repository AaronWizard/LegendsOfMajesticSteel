tool
class_name Actor
extends TileObject

class _AnimationTimes:
	const MOVE := 0.15

	const ATTACK_PREP := 0.15
	const ATTACK_HIT := 0.1
	const ATTACK_PAUSE := 0.05
	const ATTACK_RECOVER := 0.1

	const HIT_REACT := 0.1
	const HIT_RECOVER := 0.2

	const BLOOD := 0.3


class _AnimationDistances:
	const ATTACK_PREP := 0.25
	const ATTACK_HIT_REDUCED := 0.25
	const ATTACK_HIT := 0.5

	const HIT_REACT := 0.25
	const DEATH := 0.5


const _WALK_FRAME := 0
const _REACT_FRAME := 2
const _ACTION_FRAME := 3

signal move_finished

signal attack_hit
signal attack_finished

signal hit_reaction_finished

signal dying
signal died

enum Faction { PLAYER, ENEMY }
enum Pose { IDLE, WALK, ACTION, REACT, DEATH }

export var character_name := "Actor"

export var actor_definition: Resource setget set_actor_definition

export(Faction) var faction := Faction.ENEMY

var portrait: Texture setget , get_portrait

var skills := []

var range_data: RangeData

var is_alive: bool setget , get_is_alive

var turn_finished: bool setget , get_turn_finished
var round_finished: bool setget , get_round_finished

var target_visible: bool setget set_target_visible, get_target_visible
var stamina_modifier: int setget set_stamina_modifier, get_stamina_modifier

var pose: int = Pose.IDLE setget set_pose

var _did_skill: bool = false
var _turns_left: int = false

var _stamina_bar_animating := false

onready var stats := $Stats as Stats

onready var remote_transform := $Center/Offset/RemoteTransform2D \
		as RemoteTransform2D

onready var _anim := $AnimationPlayer as AnimationPlayer
onready var _tween := $Tween as Tween

onready var _sprite := $Center/Offset/Sprite as Sprite
onready var _blood_splatter := $Center/BloodSplatter \
		as Particles2D

onready var _stamina_bar := $Center/Offset/Sprite/StaminaBar as StaminaBar
onready var _condition_icons := $Center/Offset/Sprite/ConditionIcons \
		as ConditionIcons
onready var _wait_icon := $WaitIcon as AnimatedSprite

onready var _target_cursor := $TargetCursor as TargetCursor

onready var _step_sound := $StepSound as AudioStreamPlayer
onready var _melee_attack_sound := $MeleeAttackSound as AudioStreamPlayer
onready var _hit_sound := $HitSound as AudioStreamPlayer
onready var _death_sound := $DeathSound as AudioStreamPlayer


func _ready() -> void:
	._ready()
	if not Engine.editor_hint:
		assert(actor_definition)
		var ad := actor_definition as ActorDefinition
		skills = ad.skills

		_stamina_bar.max_stamina = stats.max_stamina
		_condition_icons.update_icons(stats)

		_wait_icon.play()
		_randomize_idle_start()


func set_rect_size(value: Vector2) -> void:
	.set_rect_size(value)

	if _stamina_bar:
		_stamina_bar.position.y = (-rect_size.y * Constants.TILE_SIZE_V.y) / 2
	if _target_cursor:
		_target_cursor.rect_size = rect_size
	if _wait_icon:
		_wait_icon.position = rect_size * Constants.TILE_SIZE_V
	if _blood_splatter:
		var pixel_rect_size := \
				(rect_size * Constants.TILE_SIZE_V) + Vector2(8, 8)
		_blood_splatter.amount = int(max(pixel_rect_size.x, pixel_rect_size.y))
		_blood_splatter.lifetime \
				= _AnimationTimes.BLOOD * max(rect_size.x, rect_size.y)
		_blood_splatter.visibility_rect = Rect2(
				-pixel_rect_size / 2, pixel_rect_size)


func set_actor_definition(value: Resource) -> void:
	actor_definition = value

	if actor_definition:
		var ad := actor_definition as ActorDefinition
		set_rect_size(ad.rect_size)
		if _sprite:
			_sprite.texture = ad.sprite
		# Use $Stats instead of stats to work in tool mode
		($Stats as Stats).init_from_def(ad)
	else:
		set_rect_size(Vector2.ONE)
		if _sprite:
			_sprite.texture \
					= preload("res://assets/graphics/actors/fighter.png")
		skills.clear()


func get_is_alive() -> bool:
	var result := true
	if stats and not Engine.editor_hint:
		result = stats.get_is_alive()
	return result


func get_turn_finished() -> bool:
	return _did_skill


func get_round_finished() -> bool:
	return _turns_left == 0


func set_target_visible(new_value: bool) -> void:
	_target_cursor.visible = new_value


func get_portrait() -> Texture:
	var result: Texture = null
	if actor_definition:
		result = (actor_definition as ActorDefinition).portrait
	return result


func get_target_visible() -> bool:
	var result := false
	if _target_cursor:
		result = _target_cursor.visible
	return result


func set_stamina_modifier(value: int) -> void:
	if _stamina_bar:
		assert(not _stamina_bar_animating)
		_stamina_bar.modifier = value
		if _stamina_bar.modifier != 0:
			_stamina_bar.visible = true
		else:
			_stamina_bar.visible = false


func get_stamina_modifier() -> int:
	var result := 0
	if _stamina_bar and not Engine.editor_hint:
		result = int(_stamina_bar.modifier)
	return result


func start_battle() -> void:
	stats.start_battle()
	_stamina_bar.reset()


func start_round() -> void:
	_wait_icon.visible = false
	_turns_left = 1

	stats.start_round()


func start_turn() -> void:
	_did_skill = false


func take_turn() -> void:
	_did_skill = true
	_turns_left -= 1
	if get_round_finished():
		_wait_icon.visible = true


func add_condition(condition: Condition) -> void:
	stats.add_condition(condition)


func remove_condition(condition: Condition) -> void:
	stats.remove_condition(condition)


func set_pose(value: int) -> void:
	var old_pose := pose
	pose = value

	if _anim and _sprite and (old_pose != pose):
		_anim.stop(true)
		match pose:
			Pose.WALK:
				_sprite.frame = _WALK_FRAME
			Pose.REACT:
				_sprite.frame = _REACT_FRAME
			Pose.ACTION:
				_sprite.frame = _ACTION_FRAME
			Pose.DEATH:
				_anim.play("actor_death")
			_:
				_anim.play("actor_idle")


func reset_pose() -> void:
	set_pose(Pose.IDLE)


func animate_offset(new_offset: Vector2, duration: float,
		trans_type: int, ease_type: int) -> void:
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset", get_cell_offset(), new_offset,
			duration, trans_type, ease_type)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")


func move_step(target_cell: Vector2) -> void:
	assert(get_origin_cell().distance_squared_to(target_cell) == 1)

	var diff := target_cell - get_origin_cell()

	set_origin_cell(target_cell)
	set_cell_offset(-diff)

	_set_facing(diff)

	set_pose(Pose.WALK)

	_step_sound.play()
	yield(
		animate_offset(Vector2.ZERO, _AnimationTimes.MOVE,
			Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	reset_pose()
	emit_signal("move_finished")


func animate_attack(direction: Vector2, reduce_range := false,
		play_sound := true) -> void:
	var real_direction := direction.normalized()

	set_pose(Pose.ACTION)
	_set_facing(real_direction)

	var hit_pos := real_direction
	if reduce_range:
		hit_pos *= _AnimationDistances.ATTACK_HIT_REDUCED
	else:
		hit_pos *= _AnimationDistances.ATTACK_HIT

	yield(
		animate_offset(-real_direction * _AnimationDistances.ATTACK_PREP,
			_AnimationTimes.ATTACK_PREP, Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	if play_sound:
		_melee_attack_sound.play()

	yield(
		animate_offset(hit_pos, _AnimationTimes.ATTACK_PREP,
			Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	emit_signal("attack_hit")

	yield(
		animate_offset(Vector2.ZERO, _AnimationTimes.ATTACK_RECOVER,
			Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	reset_pose()
	emit_signal("attack_finished")


func animate_hit(direction: Vector2) -> void:
	set_pose(Pose.REACT)
	_hit_sound.play()

	if direction != Vector2.ZERO:
		var real_direction := direction.normalized()
		yield(
			animate_offset(real_direction * _AnimationDistances.HIT_REACT,
				_AnimationTimes.HIT_REACT, Tween.TRANS_QUART, Tween.EASE_OUT),
			"completed"
		)
		yield(
			animate_offset(Vector2.ZERO, _AnimationTimes.HIT_RECOVER,
					Tween.TRANS_QUAD, Tween.EASE_OUT),
			"completed"
		)

	reset_pose()

	if not _stamina_bar_animating:
		yield(_stamina_bar, "animation_finished")

	emit_signal("hit_reaction_finished")


func animate_death(direction: Vector2) -> void:
	var real_direction := direction.normalized()
	var new_offset := get_cell_offset() \
			+ (real_direction * _AnimationDistances.DEATH)

	emit_signal("dying")
	_hit_sound.play()
	_death_sound.play()

	var signal_waiter := SignalWaiter.new()
	signal_waiter.wait_for_signal(_hit_sound, "finished")
	signal_waiter.wait_for_signal(_death_sound, "finished")

	set_pose(Pose.DEATH)
	if direction != Vector2.ZERO:
		yield(
			animate_offset(new_offset, _anim.current_animation_length,
				Tween.TRANS_QUAD, Tween.EASE_OUT),
			"completed"
		)
	if _anim.is_playing():
		yield(_anim, "animation_finished")
	if signal_waiter.waiting:
		yield(signal_waiter, "finished")

	emit_signal("died")


func play_hit_sound() -> void:
	_hit_sound.play()


func _randomize_idle_start() -> void:
	if not Engine.editor_hint:
		assert(_anim.current_animation == "actor_idle")
		randomize()
		var offset := rand_range(0, _anim.current_animation_length)
		_anim.advance(offset)


func _set_facing(direction: Vector2) -> void:
	if direction.x < 0:
		_sprite.flip_h = true
	elif direction.x > 0:
		_sprite.flip_h = false
	# else change nothing


func _on_Stats_stamina_changed(old_stamina: int, new_stamina: int) -> void:
	if get_is_alive():
		_stamina_bar_animating = true
		_stamina_bar.visible = true
		_stamina_bar.animate_change(new_stamina - old_stamina)


func _on_StaminaBar_animation_finished() -> void:
	_stamina_bar_animating = false
	_stamina_bar.visible = false


func _on_Stats_conditions_changed() -> void:
	_condition_icons.update_icons(stats)
