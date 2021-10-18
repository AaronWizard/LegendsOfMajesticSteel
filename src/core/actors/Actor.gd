tool
class_name Actor, "res://assets/editor/actor.png"
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
const _REACT_FRAME := 1
const _ACTION_FRAME := 2

signal animation_finished

signal attack_hit

signal dying
signal died

enum Faction { PLAYER, ENEMY }
enum Pose { IDLE, WALK, ACTION, REACT, DEATH }

export var character_name := "Actor"

export var actor_definition: Resource setget set_actor_definition

export(Faction) var faction := Faction.ENEMY

var portrait: Texture setget , get_portrait

var turn_status: ActorTurnStatus setget , get_turn_status
var stats: Stats setget , get_stats
var attack_skill: Node setget , get_attack
var skills: Array setget , get_skills

var walk_range: WalkRange

var target_visible: bool setget set_target_visible, get_target_visible
var stamina_modifier: int setget set_stamina_modifier, get_stamina_modifier

var pose: int = Pose.IDLE setget set_pose

var animating: bool setget , get_is_animating

var virtual_origin_cell: Vector2 setget set_virtual_origin_cell

var _animating := false
var _stamina_bar_animating := false

var _using_virtual_origin := false

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
		set_actor_definition(actor_definition)

		_stamina_bar.max_stamina = get_stats().max_stamina
		_condition_icons.update_icons(get_stats())

		_wait_icon.play()
		_randomize_idle_start()


# Override
func set_origin_cell(value: Vector2) -> void:
	.set_origin_cell(value)
	_using_virtual_origin = false


# Override
func get_origin_cell() -> Vector2:
	var result := .get_origin_cell()
	if _using_virtual_origin:
		result = virtual_origin_cell
	return result


# Override
func set_rect_size(value: Vector2) -> void:
	.set_rect_size(value)

	if _stamina_bar:
		_stamina_bar.position = Vector2(
			0, (-rect_size.y * Constants.TILE_SIZE_V.y) / 2
		)
	if _condition_icons:
		_condition_icons.position = (rect_size.y * Constants.TILE_SIZE_V) / -2

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


func set_virtual_origin_cell(value: Vector2) -> void:
	virtual_origin_cell = value
	_using_virtual_origin = true


func reset_virtual_origin() -> void:
	virtual_origin_cell = Vector2.ZERO
	_using_virtual_origin = false


func set_actor_definition(value: Resource) -> void:
	actor_definition = value

	_clear_skills()
	if actor_definition:
		var ad := actor_definition as ActorDefinition
		set_rect_size(ad.rect_size)
		if _sprite:
			_sprite.texture = ad.sprite

		if not Engine.editor_hint:
			get_stats().init_from_def(ad)

			if ad.attack_skill:
				var new_attack_skill := ad.attack_skill.instance()
				$Attack.add_child(new_attack_skill)

			for s in ad.skills:
				var skill_scene := s as PackedScene
				var skill := skill_scene.instance() as Node
				$Skills.add_child(skill)
	else:
		set_rect_size(Vector2.ONE)
		if _sprite:
			_sprite.texture \
					= preload("res://assets/graphics/actors/fighter.png")


func set_target_visible(new_value: bool) -> void:
	_target_cursor.visible = new_value


func get_turn_status() -> ActorTurnStatus:
	var result: ActorTurnStatus = null
	if $TurnStatus:
		result = $TurnStatus as ActorTurnStatus
	return result


func get_stats() -> Stats:
	var result: Stats = null
	if $Stats:
		result = $Stats as Stats
	return result


func get_attack() -> Node:
	var result: Node = null
	if $Attack and $Attack.get_child_count() > 0:
		assert($Attack.get_child_count() == 1)
		result = $Attack.get_child(0)
	return result


func get_skills() -> Array:
	var result := []
	if $Skills:
		result = $Skills.get_children()
	return result


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
	get_stats().start_battle()
	_stamina_bar.reset()
	get_turn_status().start_round()


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


func get_is_animating() -> bool:
	return _animating


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

	set_facing(diff)

	set_pose(Pose.WALK)

	_step_sound.play()
	yield(
		animate_offset(Vector2.ZERO, _AnimationTimes.MOVE,
			Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	reset_pose()


func move_path(path: Array) -> void:
	for c in path:
		var cell := c as Vector2
		yield(move_step(cell), "completed")


func animate_attack(direction: Vector2, reduce_lunge := false,
		play_sound := true) -> void:
	_animating = true

	var real_direction := direction.normalized()

	set_pose(Pose.ACTION)
	set_facing(real_direction)

	var hit_pos := real_direction
	if reduce_lunge:
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

	_animating = false
	emit_signal("animation_finished")


func animate_death(direction: Vector2, play_hit_sound: bool) -> void:
	emit_signal("dying")

	_stamina_bar.visible = false

	var real_direction := direction.normalized()
	var new_offset := get_cell_offset() \
			+ (real_direction * _AnimationDistances.DEATH)

	var waiter := SignalWaiter.new()

	if play_hit_sound:
		waiter.wait_for_signal(_hit_sound, "finished")
		_hit_sound.play()

	waiter.wait_for_signal(_death_sound, "finished")
	_death_sound.play()

	set_pose(Pose.DEATH)
	if direction != Vector2.ZERO:
		yield(
			animate_offset(new_offset, _anim.current_animation_length,
				Tween.TRANS_QUAD, Tween.EASE_OUT),
			"completed"
		)
	if _anim.is_playing():
		yield(_anim, "animation_finished")
	if waiter.waiting:
		yield(waiter, "finished")

	emit_signal("died")


func play_hit_sound() -> void:
	_hit_sound.play()


func set_facing(direction: Vector2) -> void:
	if direction.x < 0:
		_sprite.flip_h = true
	elif direction.x > 0:
		_sprite.flip_h = false
	# else change nothing


func _randomize_idle_start() -> void:
	if not Engine.editor_hint:
		assert(_anim.current_animation == "actor_idle")
		var offset := rand_range(0, _anim.current_animation_length)
		_anim.advance(offset)


func _clear_skills() -> void:
	for a in $Attack.get_children():
		var attack := a as Node
		attack.queue_free()
	for s in $Skills.get_children():
		var skill := s as Node
		skill.queue_free()


func _animate_staminabar(change: int) -> void:
	_stamina_bar_animating = true
	_stamina_bar.visible = true
	_stamina_bar.animate_change(change)


func _animate_hit(direction: Vector2) -> void:
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
	else:
		_anim.play("actor_shake")
		yield(_anim, "animation_finished")

	reset_pose()


func _on_StaminaBar_animation_finished() -> void:
	_stamina_bar_animating = false
	_stamina_bar.visible = false


func _on_TurnStatus_round_started() -> void:
	_wait_icon.visible = false
	get_stats().start_round()


func _on_TurnStatus_round_finished() -> void:
	_wait_icon.visible = true


func _on_Stats_conditions_changed() -> void:
	_condition_icons.update_icons(get_stats())


func _on_Stats_damaged(amount: int, direction: Vector2,
		standard_hit_anim: bool) -> void:
	_animating = true
	if get_stats().is_alive:
		_animate_staminabar(-amount)
		if standard_hit_anim:
			yield(_animate_hit(direction), "completed")
		if _stamina_bar_animating:
			yield(_stamina_bar, "animation_finished")
	else:
		if standard_hit_anim:
			yield(animate_death(direction, true), "completed")
	_animating = false
	emit_signal("animation_finished")


func _on_Stats_healed(amount: int) -> void:
	_animate_staminabar(amount)
