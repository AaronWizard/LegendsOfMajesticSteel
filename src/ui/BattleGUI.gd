class_name BattleGUI
extends CanvasLayer

signal skill_selected(skill_index)
signal skill_cleared

signal wait_started

const _ACTION_MENU_ROTATION_ONE_B := 90
const _ACTION_MENU_ROTATION_TWO_B := 0
const _ACTION_MENU_ROTATION_THREE_B := 90

var current_actor: Actor = null setget set_current_actor
var show_cancel: bool setget set_show_cancel, get_show_cancel

onready var turn_queue := $TurnQueuePanel as TurnQueuePanel

onready var _current_actor_status := $HBoxContainer/CurrentActorStatus \
		as ActorStatusPanel

onready var _action_menu_pivot := $ActionMenuPivot as Control

onready var _action_menu := $ActionMenuPivot/ActionMenu as RadialContainer
onready var _attack_button := $ActionMenuPivot/ActionMenu/Attack as Control
onready var _skills_button := $ActionMenuPivot/ActionMenu/Skill as Control

onready var _cancel_button := $HBoxContainer/CancelSkill as Control

func set_current_actor(value: Actor) -> void:
	current_actor = value
	_current_actor_status.clear()

	_current_actor_status.visible = current_actor != null

	if current_actor:
		_current_actor_status.set_actor(current_actor)

		_attack_button.visible = current_actor.stats.skills.size() > 0
		_skills_button.visible = current_actor.stats.skills.size() > 1

		match (current_actor.stats.skills.size()):
			0:
				_action_menu.base_rotation = _ACTION_MENU_ROTATION_ONE_B
			1:
				_action_menu.base_rotation = _ACTION_MENU_ROTATION_TWO_B
			_:
				_action_menu.base_rotation = _ACTION_MENU_ROTATION_THREE_B


func set_show_cancel(new_value: bool) -> void:
	_cancel_button.visible = new_value


func get_show_cancel() -> bool:
	return _cancel_button.visible


func show_action_menu(position: Vector2) -> void:
	_action_menu_pivot.visible = true
	_action_menu_pivot.rect_position = position


func hide_action_menu() -> void:
	_action_menu_pivot.visible = false


func _on_CurrentActorStatus_portrait_pressed() -> void:
	pass # Replace with function body.


func _on_Attack_pressed() -> void:
	emit_signal("skill_selected", 0)


func _on_Skill_pressed() -> void:
	pass # Replace with function body.


func _on_Wait_pressed() -> void:
	emit_signal("wait_started")


func _on_CancelSkill_pressed() -> void:
	emit_signal("skill_cleared")
