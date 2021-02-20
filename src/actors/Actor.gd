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
	const ATTACK_PREP := 0.5
	const ATTACK_HIT_REDUCED := 0.5
	const ATTACK_HIT := 0.75

	const HIT_REACT := 0.25
	const DEATH := 0.5


enum Pose { IDLE, WALK, ACTION, REACT, DEATH }

const _WALK_FRAME := 0
const _REACT_FRAME := 2
const _ACTION_FRAME := 3

signal conditions_changed

signal move_finished

signal attack_hit
signal attack_finished

signal hit_reaction_finished

signal dying
signal died

enum Faction { PLAYER, ENEMY }

export var character_name := "Actor"

export var actor_definition: Resource setget set_actor_definition

export(Faction) var faction := Faction.ENEMY

var portrait: Texture setget , get_portrait

var stats: Stats

var skills := []
var conditions := []

var range_data: RangeData

var is_alive: bool setget , get_is_alive

var turn_finished: bool setget , get_turn_finished
var round_finished: bool setget , get_round_finished

var target_visible: bool setget set_target_visible, get_target_visible

var pose: int = Pose.IDLE setget set_pose

var _did_skill: bool = false
var _turns_left: int = false

var _stamina_bar_animating := false

onready var remote_transform := $Center/Offset/RemoteTransform2D \
		as RemoteTransform2D

onready var _anim := $AnimationPlayer as AnimationPlayer
onready var _tween := $Tween as Tween

onready var _sprite := $Center/Offset/Sprite as Sprite
onready var _blood_splatter := $Center/BloodSplatter \
		as Particles2D

onready var _stamina_bar := $Center/Offset/Sprite/StaminaBar as StaminaBar

onready var _wait_icon := $WaitIcon as AnimatedSprite

onready var _target_cursor := $TargetCursor as TargetCursor


func _ready() -> void:
	._ready()
	if not Engine.editor_hint:
		assert(actor_definition)
		# warning-ignore:return_value_discarded
		stats.connect("stamina_changed", self, "_on_stats_stamina_changed")
		_stamina_bar.max_stamina = stats.max_stamina
		_wait_icon.play()
		_randomize_idle_start()


func set_rect_size(value: Vector2) -> void:
	.set_rect_size(value)

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

		stats = ad.create_stats()
		skills = ad.skills
	else:
		set_rect_size(Vector2.ONE)
		if _sprite:
			_sprite.texture \
					= preload("res://assets/graphics/actors/fighter.png")
		stats = null
		skills.clear()


func get_is_alive() -> bool:
	return stats.is_alive


func get_turn_finished() -> bool:
	return _did_skill


func get_round_finished() -> bool:
	return _turns_left == 0


func set_target_visible(new_value: bool) -> void:
	_target_cursor.visible = new_value


func get_portrait() -> Texture:
	return (actor_definition as ActorDefinition).portrait


func get_target_visible() -> bool:
	return _target_cursor.visible


func start_battle() -> void:
	stats.start_battle()
	_stamina_bar.reset()


func start_round() -> void:
	_wait_icon.visible = false
	_turns_left = 1

	for c in conditions:
		var condition := c as Condition
		condition.start_round()


func start_turn() -> void:
	_did_skill = false


func take_turn() -> void:
	_did_skill = true
	_turns_left -= 1
	if get_round_finished():
		_wait_icon.visible = true


func add_condition(condition: Condition) -> void:
	if conditions.find(condition) == -1:
		stats.add_condition_effect(condition.effect)
		# warning-ignore:return_value_discarded
		condition.connect("finished", self, "remove_condition", [condition])
		conditions.append(condition)
		emit_signal("conditions_changed")


func remove_condition(condition: Condition) -> void:
	if conditions.find(condition) > -1:
		stats.remove_condition_effect(condition.effect)
		condition.disconnect("finished", self, "remove_condition")
		conditions.erase(condition)
		emit_signal("conditions_changed")


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

	yield(
		animate_offset(Vector2.ZERO, _AnimationTimes.MOVE,
			Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	set_pose(Pose.IDLE)
	emit_signal("move_finished")


func animate_attack(direction: Vector2, reduced_lunge := false) -> void:
	var real_direction := direction.normalized()

	set_pose(Pose.ACTION)
	_set_facing(real_direction)

	yield(
		animate_offset(-real_direction * _AnimationDistances.ATTACK_PREP,
			_AnimationTimes.ATTACK_PREP, Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	var hit_pos := real_direction
	if reduced_lunge:
		hit_pos *= _AnimationDistances.ATTACK_HIT_REDUCED
	else:
		hit_pos *= _AnimationDistances.ATTACK_HIT

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

	set_pose(Pose.IDLE)
	emit_signal("attack_finished")


func animate_hit(direction: Vector2) -> void:
	var real_direction := direction.normalized()

	set_pose(Pose.REACT)

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

	set_pose(Pose.IDLE)

	if not _stamina_bar_animating:
		yield(_stamina_bar, "animation_finished")

	emit_signal("hit_reaction_finished")


func animate_death(direction: Vector2) -> void:
	var real_direction := direction.normalized()

	emit_signal("dying")

	set_pose(Pose.DEATH)
	yield(
		animate_offset(real_direction * _AnimationDistances.DEATH,
			_anim.current_animation_length, Tween.TRANS_QUAD, Tween.EASE_OUT),
		"completed"
	)

	emit_signal("died")


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


func _on_stats_stamina_changed(_old_stamina: int, new_stamina: int) -> void:
	if get_is_alive():
		_stamina_bar_animating = true
		_stamina_bar.visible = true
		_stamina_bar.animate_change(new_stamina - _old_stamina)


func _on_StaminaBar_animation_finished() -> void:
	_stamina_bar_animating = false
	_stamina_bar.visible = false
