tool
class_name Actor
extends TileObject

signal move_finished
signal attack_hit
signal attack_finished
signal hit_reaction_finished

signal stamina_animation_finished

signal dying
signal died

enum Faction { PLAYER, ENEMY }

const _MOVE_TIME := 0.15

const _ATTACK_PREP_DIST := 0.5
const _ATTACK_HIT_DIST_REDUCED := 0.5
const _ATTACK_HIT_DIST := 0.75

const _ATTACK_PREP_TIME := 0.15
const _ATTACK_HIT_TIME := 0.1
const _ATTACK_PAUSE_TIME := 0.05
const _ATTACK_RECOVER_TIME := 0.1

const _HIT_REACT_DIST := 0.25

const _HIT_REACT_TIME := 0.1
const _HIT_RECOVER_TIME := 0.2

const _DEATH_DIST := 0.5
const _DEATH_TIME := 0.3

const _BLOOD_TIME := 0.3

const _WALK_FRAME := 0
const _REACT_FRAME := 2
const _ACTION_FRAME := 3

export var character_name := "Actor"

export(Resource) var stat_resource: Resource \
		setget set_stat_resource, get_stat_resource

export(Faction) var faction := Faction.ENEMY

var stats: Stats
var target_visible: bool setget set_target_visible, get_target_visible

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
		_blood_splatter.lifetime = _BLOOD_TIME * max(rect_size.x, rect_size.y)
		_blood_splatter.visibility_rect = Rect2(
				-pixel_rect_size / 2, pixel_rect_size)


func move_step(target_cell: Vector2) -> void:
	assert(get_cell().distance_squared_to(target_cell) == 1)

	var origin_cell := get_cell()
	var diff := target_cell - origin_cell

	set_cell(target_cell)
	set_cell_offset(-diff)

	_set_facing(diff)

	_anim.stop(true)
	_sprite.frame = _WALK_FRAME

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			-diff, Vector2.ZERO, _MOVE_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	_anim.play() # Play idle animation again
	emit_signal("move_finished")


func animate_attack(direction: Vector2, reduced_lunge := false) -> void:
	assert(direction.is_normalized())

	_anim.stop(true)
	_sprite.frame = _ACTION_FRAME

	_set_facing(direction)

	var prep_pos := -direction * _ATTACK_PREP_DIST
	var attack_pos: Vector2
	if reduced_lunge:
		attack_pos = direction * _ATTACK_HIT_DIST_REDUCED
	else:
		attack_pos = direction * _ATTACK_HIT_DIST

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			Vector2.ZERO, prep_pos, _ATTACK_PREP_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			prep_pos, attack_pos, _ATTACK_HIT_TIME,
			Tween.TRANS_QUAD, Tween.EASE_IN,
			_ATTACK_PREP_TIME
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")
	emit_signal("attack_hit")

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			attack_pos, Vector2.ZERO, _ATTACK_RECOVER_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT,
			_ATTACK_PAUSE_TIME
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	_anim.play() # Play idle animation again
	emit_signal("attack_finished")


func animate_hit(direction: Vector2) -> void:
	assert(direction.is_normalized())

	_anim.stop(true)
	_sprite.frame = _REACT_FRAME

	var end := direction * _HIT_REACT_DIST

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			Vector2.ZERO, end, _HIT_REACT_TIME,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			end, Vector2.ZERO, _HIT_RECOVER_TIME,
			Tween.TRANS_BACK, Tween.EASE_OUT,
			_HIT_REACT_TIME
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	_anim.play() # Play idle animation again
	emit_signal("hit_reaction_finished")


func animate_death(direction: Vector2) -> void:
	assert(direction.is_normalized())

	emit_signal("dying")

	_blood_splatter.emitting = true
	_anim.stop(true)
	_sprite.frame = _REACT_FRAME

	var end := direction * _DEATH_DIST

	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			self, "cell_offset",
			Vector2.ZERO, end, _DEATH_TIME,
			Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			_sprite.material, "shader_param/dissolve",
			0, 1, _DEATH_TIME
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	yield(_tween, "tween_all_completed")

	emit_signal("died")


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


func _on_BattleStats_round_started() -> void:
	_wait_icon.visible = false


func _on_BattleStats_turn_taken() -> void:
	if battle_stats.round_finished:
		_wait_icon.visible = true
