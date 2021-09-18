class_name PlayerActorTargetState
extends PickActorActionState

export var player_move_state_path: NodePath

var _skill_index: int

var _have_target := false
var _skill_target: Vector2

var _predicted_damage_actors: Array

onready var _pick_target_sound := $PickTargetSound as AudioStreamPlayer

onready var _player_move_state := get_node(player_move_state_path) as State


func start(data: Dictionary) -> void:
	_game.interface.mouse.dragging_enabled = true
	# warning-ignore:return_value_discarded
	_game.interface.mouse.connect("click", self, "_mouse_click")

	_skill_index = data.skill_index as int


	# warning-ignore:return_value_discarded
	_game.interface.gui.connect("skill_cleared", self, "_skill_cleared")

	_game.interface.gui.show_skill_panel(
		_get_skill(),
		not _game.current_actor.range_data.skill_is_valid_at_cell(
			_game.current_actor.origin_cell, _skill_index
		)
	)

	var targeting_data := _game.current_actor.range_data.get_targeting_data(
			_game.current_actor.origin_cell, _skill_index)
	_game.interface.map_highlights.set_targets(targeting_data.target_range)
	_game.interface.map_highlights.moves_visible = false
	_game.interface.map_highlights.clear_other_moves()


func end() -> void:
	_game.interface.mouse.dragging_enabled = false
	_game.interface.mouse.disconnect("click", self, "_mouse_click")

	_game.interface.gui.disconnect("skill_cleared", self, "_skill_cleared")

	_game.interface.gui.hide_skill_panel()

	_game.interface.map_highlights.target_cursor_visible = false
	_game.interface.map_highlights.clear_targets()
	_game.interface.map_highlights.clear_aoe()
	_game.interface.map_highlights.moves_visible = true

	_clear_predicted_damage()

	_have_target = false


func _skill_cleared() -> void:
	emit_signal("state_change_requested", _player_move_state)


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _game.interface.current_map.get_mouse_cell()
	if _have_target:
		_confirm_target(target_cell)
	else:
		_set_target(target_cell)


func _set_target(target_cell: Vector2) -> void:
	var targeting_data := _game.current_actor.range_data.get_targeting_data(
			_game.current_actor.origin_cell, _skill_index)

	if target_cell in targeting_data.valid_targets:
		_pick_target_sound.play()

		_game.interface.map_highlights.target_cursor_visible = true
		_game.interface.map_highlights.target_cursor_cell = target_cell

		var aoe := targeting_data.get_aoe(target_cell)
		_game.interface.map_highlights.set_aoe(aoe)

		_show_predicted_damage(targeting_data, target_cell)

		_have_target = true
		_skill_target = target_cell


func _confirm_target(target_cell: Vector2) -> void:
	if _skill_target == target_cell:
		_pick_target_sound.play()

		var skill := _get_skill()

		_do_skill(skill, target_cell)
	else:
		_set_target(target_cell)


func _get_skill() -> Skill:
	return _game.current_actor.skills[_skill_index] as Skill


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
