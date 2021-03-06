class_name BattleGUI
extends CanvasLayer

signal skill_selected(skill_index)
signal skill_cleared

signal wait_started

var current_actor: Actor = null setget set_current_actor
var other_actor: Actor = null setget set_other_actor

onready var turn_queue := $TurnQueuePanel as TurnQueuePanel

onready var _current_actor_status := $CurrentActorStatus as ActorStatusPanel
onready var _other_actor_status := $OtherActorStatus as ActorStatusPanel

onready var _skill_panel := $SkillPanel as SkillPanel

onready var _action_menu_region := $ActionMenuRegion as Control

onready var _action_menu := $ActionMenu as ActionMenu


func set_current_actor(value: Actor) -> void:
	current_actor = value

	_current_actor_status.clear()
	_current_actor_status.visible = current_actor != null
	_action_menu.clear_skills()

	if current_actor:
		_current_actor_status.set_actor(current_actor)
		_action_menu.set_skills(current_actor.skills)


func set_other_actor(value: Actor) -> void:
	other_actor = value

	_other_actor_status.clear()
	_other_actor_status.visible = other_actor != null

	if other_actor:
		_other_actor_status.set_actor(other_actor)


func show_action_menu(screen_position: Vector2) -> void:
	var rect := _action_menu_region.get_rect()
	var pivot_position := Vector2(screen_position)

	if not rect.has_point(pivot_position):
		if pivot_position.x > rect.end.x:
			pivot_position.x = rect.end.x
		elif pivot_position.x < rect.position.x:
			pivot_position.x = rect.position.x

		if pivot_position.y < rect.position.y:
			pivot_position.y = rect.position.y
		elif pivot_position.y > rect.end.y:
			pivot_position.y = rect.end.y

	_action_menu.visible = true
	_action_menu.position = pivot_position


func show_skill_panel(skill: Skill) -> void:
	_skill_panel.set_skill(skill)
	_skill_panel.visible = true


func hide_skill_panel() -> void:
	_skill_panel.clear()
	_skill_panel.visible = false


func get_action_menu_pos() -> Vector2:
	return _action_menu.position


func hide_action_menus() -> void:
	_action_menu.visible = false
	_action_menu.reset_menu()


func _on_CurrentActorStatus_portrait_pressed() -> void:
	pass # Replace with function body.


func _on_SkillPanel_cancelled() -> void:
	_skill_panel.visible = false
	emit_signal("skill_cleared")


func _on_ActionMenu_attack_pressed() -> void:
	emit_signal("skill_selected", 0)


func _on_ActionMenu_wait_pressed() -> void:
	emit_signal("wait_started")


func _on_ActionMenu_skill_selected(skill_index: int) -> void:
	emit_signal("skill_selected", skill_index)
