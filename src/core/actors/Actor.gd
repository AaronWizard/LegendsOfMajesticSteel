tool
class_name Actor, "res://assets/editor/actor.png"
extends TileObject

const _WALK_FRAME := 0
const _ACTION_FRAME := 0
const _REACT_FRAME := 1

const _BASE_BLOOD_TIME := 0.3

const _FAKE_DEATH_FLY_SPEED := 200

signal animation_finished # Emitted using animations
# warning-ignore:unused_signal
signal attack_hit # Emitted using animations

signal dying
signal died

enum Faction { PLAYER, ENEMY }
enum Pose { IDLE, WALK, ACTION, REACT }

export var character_name := "Actor"

export var actor_definition: Resource setget set_actor_definition

export(Faction) var faction := Faction.ENEMY

export var fakes_death := false

# Used for animations that depend on a direction
export var slide_direction := Vector2.ZERO setget set_slide_direction
export var slide_distance := 0.0 setget set_slide_distance

var portrait: Texture setget , get_portrait

var round_finished := false

var stats: Stats setget , get_stats
var attack_skill: Node setget , get_attack
var skills: Array setget , get_skills

# Includes attack skill. Does not include skills that need more energy.
var all_active_skills: Array setget , get_all_active_skills

var target_visible: bool setget set_target_visible, get_target_visible
var other_target_visible: bool setget \
		set_other_target_visible, get_other_target_visible

var stamina_bar_modifier: int setget set_stamina_bar_modifier, \
		get_stamina_bar_modifier

var animating: bool setget , get_is_animating

var virtual_origin_cell: Vector2 setget set_virtual_origin_cell

var _animating := false
var _stamina_bar_animating := false

var _using_virtual_origin := false

var _fly_direction := Vector2.ZERO

onready var remote_transform := $Center/Offset/RemoteTransform2D \
		as RemoteTransform2D

onready var _anim := $AnimationPlayer as AnimationPlayer
onready var _audio := $AudioStreamPlayer as AudioStreamPlayer
onready var _audio_2 := $AudioStreamPlayer2 as AudioStreamPlayer

onready var _tween := $Tween as Tween

onready var _sprite := $Center/Offset/Sprite as Sprite
onready var _blood_splatter := $Center/BloodSplatter \
		as CPUParticles2D

onready var _visibility := $Center/Offset/Sprite/VisibilityNotifier2D \
		as VisibilityNotifier2D

onready var _stamina_bar := $Center/Offset/Sprite/StaminaBar as StaminaBar
onready var _condition_icons := $Center/Offset/Sprite/ConditionIcons \
		as ConditionIcons

onready var _target_cursor := $TargetCursor as TargetCursor
onready var _other_target_cursor := $OtherTargetCursor as TargetCursor

onready var _hit_sound := $HitSound as AudioStreamPlayer


func _ready() -> void:
	._ready()

	set_process(false)

	if not Engine.editor_hint:
		set_actor_definition(actor_definition)
		_init_stats_and_skills()

		_stamina_bar.max_stamina = get_stats().max_stamina
		_condition_icons.update_icons(get_stats())

		_randomize_idle_start()


func _process(delta: float) -> void:
	# For fake deaths
	if not Engine.editor_hint and (_fly_direction.length_squared() > 0):
		position += _fly_direction * _FAKE_DEATH_FLY_SPEED * delta


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
func set_size(value: int) -> void:
	.set_size(value)

	if _stamina_bar:
		_stamina_bar.position = Vector2(
			0, (-size * Constants.TILE_SIZE_V.y) / 2
		)
	if _condition_icons:
		_condition_icons.position = (size * Constants.TILE_SIZE_V) / -2

	if _target_cursor:
		_target_cursor.rect_size = Vector2(size, size)
	if _other_target_cursor:
		_other_target_cursor.rect_size = Vector2(size, size)
	if _blood_splatter:
		var splatter_size := size * Constants.TILE_SIZE * 2
		_blood_splatter.amount = splatter_size
		_blood_splatter.lifetime = _BASE_BLOOD_TIME * size
	if _visibility:
		var bounds_rect := Rect2(
				(Vector2(size, size) / -2.0) * Constants.TILE_SIZE,
				Vector2(size, size) * Constants.TILE_SIZE
		)
		_visibility.rect = bounds_rect


func set_virtual_origin_cell(value: Vector2) -> void:
	virtual_origin_cell = value
	_using_virtual_origin = true


func reset_virtual_origin() -> void:
	virtual_origin_cell = Vector2.ZERO
	_using_virtual_origin = false


func set_slide_direction(value: Vector2) -> void:
	slide_direction = value.normalized()
	_set_offset_from_slide()


func set_slide_distance(value: float) -> void:
	slide_distance = value
	_set_offset_from_slide()


func set_actor_definition(value: Resource) -> void:
	actor_definition = value

	if actor_definition:
		var ad := actor_definition as ActorDefinition
		set_size(ad.size)
		if _sprite:
			_sprite.texture = ad.sprite
	else:
		set_size(1)
		if _sprite:
			_sprite.texture \
					= preload("res://assets/graphics/actors/fighter.png")


func get_target_visible() -> bool:
	var result := false
	if _target_cursor:
		result = _target_cursor.visible
	return result


func set_target_visible(new_value: bool) -> void:
	_target_cursor.visible = new_value


func get_other_target_visible() -> bool:
	var result := false
	if _other_target_cursor:
		result = _other_target_cursor.visible
	return result


func set_other_target_visible(new_value: bool) -> void:
	_other_target_cursor.visible = new_value


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


func charge_skills() -> void:
	for s in get_skills():
		s.charge()


# Includes attack skill. Does not include skills that need more energy.
func get_all_active_skills() -> Array:
	var result := []

	var attack := get_attack()
	if attack:
		result.append(attack)
	for s in get_skills():
		if s.current_cooldown == 0:
			result.append(s)

	return result


# Includes attack skill. Includes skills that will be charged next round if
# actor acts next round.
func get_next_turn_skills() -> Array:
	var result := []

	var attack := get_attack()
	if attack:
		result.append(attack)

	for s in get_skills():
		var current_cooldown := s.current_cooldown as int
		var skill_ready_now := current_cooldown == 0
		var skill_ready_next_turn := round_finished and (current_cooldown == 1)
		if skill_ready_now or skill_ready_next_turn:
			result.append(s)

	return result


func get_portrait() -> Texture:
	var result: Texture = null
	if actor_definition:
		result = (actor_definition as ActorDefinition).portrait
	return result


func set_stamina_bar_modifier(value: int) -> void:
	if _stamina_bar:
		assert(not _stamina_bar_animating)
		_stamina_bar.modifier = value
		if _stamina_bar.modifier != 0:
			_stamina_bar.visible = true
		else:
			_stamina_bar.visible = false


func get_stamina_bar_modifier() -> int:
	var result := 0
	if _stamina_bar and not Engine.editor_hint:
		result = int(_stamina_bar.modifier)
	return result


func start_battle() -> void:
	get_stats().start_battle()

	for s in get_skills():
		s.start_battle()

	_stamina_bar.reset()


func start_round(first_round: bool) -> void:
	if not first_round:
		charge_skills()
	get_stats().start_round()
	round_finished = false


func set_pose(pose: int) -> void:
	if _anim and _sprite:
		_anim.stop(true)
		match pose:
			Pose.WALK:
				_sprite.frame = _WALK_FRAME
			Pose.REACT:
				_sprite.frame = _REACT_FRAME
			Pose.ACTION:
				_sprite.frame = _ACTION_FRAME
			_:
				_anim.play("idle")


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

	var direction := target_cell - get_origin_cell()

	set_facing(direction)
	set_slide_direction(direction)

	set_origin_cell(target_cell)
	set_cell_offset(-direction)

	_anim.play("move_step")
	yield(_anim, "animation_finished")

	reset_pose()


func animate_attack(direction: Vector2, reduce_lunge := false,
		play_sound := true) -> void:
	_animating = true

	set_facing(direction)
	set_slide_direction(direction)

	if play_sound:
		_audio.volume_db = linear2db(1)
	else:
		_audio.volume_db = linear2db(0)

	if reduce_lunge:
		_anim.play("attack_reduced")
	else:
		_anim.play("attack")
	yield(_anim, "animation_finished")

	_audio.volume_db = linear2db(1)
	_animating = false

	reset_pose()


func animate_death(direction: Vector2, play_hit_sound: bool) -> void:
	emit_signal("dying")

	if play_hit_sound:
		_audio_2.volume_db = linear2db(1)
	else:
		_audio_2.volume_db = linear2db(0)

	if fakes_death:
		_anim.play("fake_death")

		if direction.length_squared() > 0:
			_fly_direction = direction.normalized()
		else:
			_fly_direction = Vector2.DOWN

		set_process(true)
		yield(_visibility, "screen_exited")
	else:
		set_slide_direction(direction)
		_anim.play("death")
		yield(_anim, "animation_finished")

	_audio_2.volume_db = linear2db(1)
	emit_signal("died")


func play_hit_sound() -> void:
	_hit_sound.play()


func set_facing(direction: Vector2) -> void:
	if direction.x < 0:
		_sprite.flip_h = true
	elif direction.x > 0:
		_sprite.flip_h = false
	# else change nothing


func _set_offset_from_slide() -> void:
	set_cell_offset(slide_distance * slide_direction)


func _randomize_idle_start() -> void:
	if not Engine.editor_hint:
		assert(_anim.current_animation == "idle")
		var offset := rand_range(0, _anim.current_animation_length)
		_anim.advance(offset)


func _init_stats_and_skills():
	if actor_definition:
		var ad := actor_definition as ActorDefinition

		get_stats().init_from_def(ad)
		if ad.attack_skill:
			var new_attack_skill := ad.attack_skill.instance()
			new_attack_skill.is_attack = true
			$Attack.add_child(new_attack_skill)

		for s in ad.skills:
			var skill_scene := s as PackedScene
			var skill := skill_scene.instance() as Node
			skill.is_attack = false
			$Skills.add_child(skill)


func _animate_staminabar(change: int) -> void:
	_stamina_bar_animating = true
	_stamina_bar.visible = true
	_stamina_bar.animate_change(change)


func _animate_hit(direction: Vector2) -> void:
	if direction.length_squared() > 0:
		set_slide_direction(direction)
		_anim.play("hit")
		yield(_anim, "animation_finished")
	else:
		_anim.play("hit_shake")
		yield(_anim, "animation_finished")

	reset_pose()


func _on_StaminaBar_animation_finished() -> void:
	_stamina_bar_animating = false
	_stamina_bar.visible = false


func _on_Stats_stat_changed(_stat_type: int, _old_mod: float, _new_mod: float,
		_old_value: int, _new_value: int) -> void:
	_condition_icons.update_icons(get_stats())


func _on_Stats_damaged(amount: int, direction: Vector2,
		standard_hit_anim: bool) -> void:
	_animating = true
	if get_stats().is_alive:
		charge_skills()

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
