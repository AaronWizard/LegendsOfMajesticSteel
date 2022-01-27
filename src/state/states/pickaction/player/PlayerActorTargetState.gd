class_name PlayerActorTargetState
extends PlayerPickActorActionState

export var player_move_state_path: NodePath

var _skill: Skill
var _targetting_data: TargetingData

var _have_target := false
var _skill_target: Vector2

var _predicted_damage_actors: Array

onready var _player_move_state := get_node(player_move_state_path) as State


func start(data: Dictionary) -> void:
	.start(data)

	_skill = data.skill as Skill
	_targetting_data = _skill.get_targeting_data(
			_game.current_actor.origin_cell, _game.current_actor, _game.map)

	# warning-ignore:return_value_discarded
	_game.interface.gui.connect("skill_cleared", self, "_skill_cleared")

	_game.interface.gui.show_skill_panel(
		_skill, _targetting_data.valid_targets.size() == 0
	)

	_game.interface.map_highlights.set_targets(_targetting_data.target_range)
	_game.interface.map_highlights.moves_visible = false
	_game.interface.map_highlights.clear_other_moves()

	_game.current_actor.target_visible = false


func end() -> void:
	.end()

	_game.interface.gui.disconnect("skill_cleared", self, "_skill_cleared")

	_game.interface.gui.hide_skill_panel()

	_game.interface.map_highlights.target_cursor_visible = false
	_game.interface.map_highlights.clear_targets()
	_game.interface.map_highlights.clear_aoe()
	_game.interface.map_highlights.moves_visible = true

	_clear_predicted_damage()

	_skill = null
	_targetting_data = null
	_have_target = false

	_game.current_actor.target_visible = true


func _mouse_click(_position: Vector2) -> void:
	var target_cell := _game.interface.current_map.get_mouse_cell()
	if _have_target:
		_confirm_target(target_cell)
	else:
		_set_target(target_cell)


func _skill_cleared() -> void:
	emit_signal("state_change_requested", _player_move_state)


func _set_target(target_cell: Vector2) -> void:
	if target_cell in _targetting_data.valid_targets:
		StandardSounds.play_select()

		_game.interface.map_highlights.target_cursor_visible = true
		_game.interface.map_highlights.target_cursor_cell = target_cell

		var aoe := _targetting_data.get_aoe(target_cell)
		_game.interface.map_highlights.set_aoe(aoe)

		_show_predicted_damage(_targetting_data, target_cell)

		_have_target = true
		_skill_target = target_cell


func _confirm_target(target_cell: Vector2) -> void:
	if _skill_target == target_cell:
		StandardSounds.play_select()

		_do_skill(_skill, target_cell)
	else:
		_set_target(target_cell)


func _show_predicted_damage( \
		targeting_data: TargetingData, target_cell: Vector2) -> void:
	_clear_predicted_damage()
	var predicted_damage := targeting_data.get_predicted_damage(target_cell)
	for a in predicted_damage:
		var other_actor := a as Actor
		var damage := predicted_damage[a] as int
		other_actor.stamina_bar_modifier = damage

	_predicted_damage_actors = predicted_damage.keys()


func _clear_predicted_damage() -> void:
	for a in _predicted_damage_actors:
		var other_actor := a as Actor
		other_actor.stamina_bar_modifier = 0
	_predicted_damage_actors.clear()
