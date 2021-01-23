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

	const DEATH:= 0.3
	const BLOOD := 0.3


class _AnimationDistances:
	const ATTACK_PREP := 0.5
	const ATTACK_HIT_REDUCED := 0.5
	const ATTACK_HIT := 0.75

	const HIT_REACT := 0.25
	const DEATH := 0.5


const _WALK_FRAME := 0
const _REACT_FRAME := 2
const _ACTION_FRAME := 3

signal move_finished
signal attack_hit
signal attack_finished
signal hit_reaction_finished

signal stamina_animation_finished

signal dying
signal died

enum Faction { PLAYER, ENEMY }

export var character_name := "Actor"

export(Resource) var stat_resource: Resource \
		setget set_stat_resource, get_stat_resource

export(Faction) var faction := Faction.ENEMY

var stats: ActorDefinition
var target_visible: bool setget set_target_visible, get_target_visible

var range_data: RangeData

var turn_finished: bool setget , get_turn_finished
var round_finished: bool setget , get_round_finished

var _did_skill: bool = false
var _turns_left: int = false

onready var remote_transform := $Center/Offset/RemoteTransform2D \
		as RemoteTransform2D

onready var battle_stats := $BattleStats as BattleStats

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
		if stats:
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


func get_turn_finished() -> bool:
	return _did_skill


func get_round_finished() -> bool:
	return _turns_left == 0


func start_round() -> void:
	_wait_icon.visible = false
	_turns_left = 1


func start_turn() -> void:
	_did_skill = false


func take_turn() -> void:
	_did_skill = true
	_turns_left -= 1
	if get_round_finished():
		_wait_icon.visible = true


func move_step(target_cell: Vector2) -> void:
	assert(get_origin_cell().distance_squared_to(target_cell) == 1)

	var origin_cell := get_origin_cell()
	var diff := target_cell - origin_cell

	set_origin_cell(target_cell)
	set_cell_offset(-diff)

	_set_facing(diff)

	_anim.stop(true)
	_sprite.frame = _WALK_FRAME

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			-diff, Vector2.ZERO, _AnimationTimes.MOVE,
			Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	_anim.play() # Play idle animation again
	emit_signal("move_finished")


func animate_attack(direction: Vector2, reduced_lunge := false) -> void:
	var real_direction := direction.normalized()

	_anim.stop(true)
	_sprite.frame = _ACTION_FRAME

	_set_facing(real_direction)

	var prep_pos := -real_direction * _AnimationTimes.ATTACK_PREP
	var attack_pos: Vector2
	if reduced_lunge:
		attack_pos = real_direction * _AnimationDistances.ATTACK_HIT_REDUCED
	else:
		attack_pos = real_direction * _AnimationDistances.ATTACK_HIT

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			Vector2.ZERO, prep_pos, _AnimationTimes.ATTACK_PREP,
			Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			prep_pos, attack_pos, _AnimationTimes.ATTACK_HIT,
			Tween.TRANS_QUAD, Tween.EASE_IN,
			_AnimationTimes.ATTACK_PREP
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")
	emit_signal("attack_hit")

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			attack_pos, Vector2.ZERO, _AnimationTimes.ATTACK_RECOVER,
			Tween.TRANS_QUAD, Tween.EASE_OUT,
			_AnimationTimes.ATTACK_PAUSE
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	_anim.play() # Play idle animation again
	emit_signal("attack_finished")


func animate_hit(direction: Vector2) -> void:
	var real_direction := direction.normalized()

	_anim.stop(true)
	_sprite.frame = _REACT_FRAME

	var end := real_direction * _AnimationDistances.HIT_REACT

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			Vector2.ZERO, end, _AnimationTimes.HIT_REACT,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			end, Vector2.ZERO, _AnimationTimes.HIT_RECOVER,
			Tween.TRANS_BACK, Tween.EASE_OUT,
			_AnimationTimes.HIT_REACT
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	_anim.play() # Play idle animation again
	emit_signal("hit_reaction_finished")


func animate_death(direction: Vector2) -> void:
	var real_direction := direction.normalized()

	emit_signal("dying")

	_blood_splatter.emitting = true
	_anim.stop(true)
	_sprite.frame = _REACT_FRAME

	var end := real_direction * _AnimationDistances.DEATH

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			Vector2.ZERO, end, _AnimationTimes.DEATH,
			Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			_sprite.material, "shader_param/dissolve",
			0, 1, _AnimationTimes.DEATH
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	emit_signal("died")


func set_stat_resource(new_value: Resource) -> void:
	stats = new_value as ActorDefinition
	if stats:
		set_rect_size(stats.rect_size)
		if _sprite:
			_sprite.texture = stats.sprite


func get_stat_resource() -> Resource:
	return stats


func set_target_visible(new_value: bool) -> void:
	_target_cursor.visible = new_value


func get_target_visible() -> bool:
	return _target_cursor.visible


func start_battle() -> void:
	battle_stats.start_battle(stats.max_stamina)
	_stamina_bar.reset()


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


func _on_BattleStats_stamina_changed(_old_stamina: int, new_stamina: int) \
		-> void:
	if battle_stats.is_alive:
		_stamina_bar.visible = true
		_stamina_bar.animate_change(new_stamina - _old_stamina)


func _on_StaminaBar_animation_finished() -> void:
	_stamina_bar.visible = false
	emit_signal("stamina_animation_finished")
