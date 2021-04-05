class_name PlayerActorTargetState
extends PlayerState

export var move_state_path: NodePath

var _player: Player
var _actor: Actor
var _skill_index: int

var _have_target := false
var _skill_target: Vector2

var _predicted_damage_actors: Array

onready var _pick_target_sound := $PickTargetSound as AudioStreamPlayer

onready var _move_state := get_node(move_state_path) as State


func start(data: Dictionary) -> void:
	.start(data)

	_player = data.player as Player
	assert(_player)
	_actor = data.actor as Actor
	assert(_actor)
	_skill_index = data.skill_index as int


	# warning-ignore:return_value_discarded
	_interface.gui.connect("skill_cleared", self, "_skill_cleared")

	_interface.gui.show_skill_panel(_get_skill())

	var targeting_data := _actor.range_data.get_targeting_data(
			_actor.origin_cell, _skill_index)
	_interface.map_highlights.set_targets(targeting_data.target_range)
	_interface.map_highlights.moves_visible = false
	_interface.map_highlights.clear_other_moves()


func end() -> void:
	.end()

	_interface.gui.disconnect("skill_cleared", self, "_skill_cleared")

	_interface.gui.hide_skill_panel()

	_interface.map_highlights.target_cursor_visible = false
	_interface.map_highlights.clear_targets()
	_interface.map_highlights.clear_aoe()
	_interface.map_highlights.moves_visible = true

	_clear_predicted_damage()

	_player = null
	_actor = null
	_have_target = false


func _skill_cleared() -> void:
	emit_signal("state_change_requested", _move_state, {
		player = _player,
		actor = _actor
	})


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _interface.current_map.get_mouse_cell()
	if _have_target:
		_confirm_target(target_cell)
	else:
		_set_target(target_cell)


func _set_target(target_cell: Vector2) -> void:
	var targeting_data := _actor.range_data.get_targeting_data(
			_actor.origin_cell, _skill_index)

	_interface.map_highlights.clear_aoe()

	if target_cell in targeting_data.valid_targets:
		_pick_target_sound.play()

		_interface.map_highlights.target_cursor_visible = true
		_interface.map_highlights.target_cursor_cell = target_cell

		var aoe := targeting_data.get_aoe(target_cell)
		_interface.map_highlights.set_aoe(aoe)

		_show_predicted_damage(targeting_data, target_cell)

		_have_target = true
		_skill_target = target_cell


func _confirm_target(target_cell: Vector2) -> void:
	if _skill_target == target_cell:
		_pick_target_sound.play()

		var skill := _get_skill()
		var action := SkillAction.new( \
				_actor, _interface.current_map, skill, target_cell)
		_player.do_action(action)
	else:
		_set_target(target_cell)


func _get_skill() -> Skill:
	return _actor.skills[_skill_index] as Skill


func _show_predicted_damage( \
		targeting_data: TargetingData, target_cell: Vector2) -> void:
	_clear_predicted_damage()
	var predicted_damage := targeting_data.get_predicted_damage(target_cell)
	for a in predicted_damage:
		var other_actor := a as Actor
		var damage := predicted_damage[a] as int
		other_actor.stamina_modifier = damage

	_predicted_damage_actors = predicted_damage.keys()


func _clear_predicted_damage() -> void:
	for a in _predicted_damage_actors:
		var other_actor := a as Actor
		other_actor.stamina_modifier = 0
	_predicted_damage_actors.clear()
