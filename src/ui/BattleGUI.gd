class_name BattleGUI
extends CanvasLayer

signal skill_selected(skill_index)
signal skill_cleared

signal wait_started

const _ACTION_MENU_ROTATION_ONE_B := 90
const _ACTION_MENU_ROTATION_TWO_B := 0
const _ACTION_MENU_ROTATION_THREE_B := 90

var current_actor: Actor = null setget set_current_actor
var other_actor: Actor = null setget set_other_actor

onready var turn_queue := $TurnQueuePanel as TurnQueuePanel

onready var _current_actor_status := $CurrentActorStatus as ActorStatusPanel
onready var _other_actor_status := $OtherActorStatus as ActorStatusPanel

onready var _skill_panel := $SkillPanel as SkillPanel

onready var _action_menu_region := $ActionMenuRegion as Control

onready var _action_menu_pivot := $ActionMenuPivot as Node2D
onready var _skill_menu_pivot := $SkillMenuPivot as Node2D

onready var _action_menu := $ActionMenuPivot/ActionMenu as RadialContainer
onready var _attack_button := $ActionMenuPivot/ActionMenu/Attack as Control
onready var _skills_button := $ActionMenuPivot/ActionMenu/Skill as Control

onready var _skill_menu := $SkillMenuPivot/SkillMenu as RadialContainer

func set_current_actor(value: Actor) -> void:
	current_actor = value

	_current_actor_status.clear()
	_current_actor_status.visible = current_actor != null
	_clear_skills()

	if current_actor:
		_current_actor_status.set_actor(current_actor)

		_attack_button.visible = current_actor.stats.skills.size() > 0
		_skills_button.visible = current_actor.stats.skills.size() > 1

		match current_actor.stats.skills.size():
			0:
				_action_menu.base_rotation = _ACTION_MENU_ROTATION_ONE_B
			1:
				_action_menu.base_rotation = _ACTION_MENU_ROTATION_TWO_B
			_:
				_action_menu.base_rotation = _ACTION_MENU_ROTATION_THREE_B

		_set_skills()


func set_other_actor(value: Actor) -> void:
	other_actor = value

	_other_actor_status.clear()
	_other_actor_status.visible = other_actor != null

	if other_actor:
		_other_actor_status.set_actor(other_actor)


func show_action_menu(screen_position: Vector2) -> void:
	_show_action_menu(_action_menu_pivot, screen_position)


func show_skill_menu(screen_position: Vector2) -> void:
	_show_action_menu(_skill_menu_pivot, screen_position)


func show_skill_panel(skill: Skill) -> void:
	_skill_panel.set_skill(skill)
	_skill_panel.visible = true


func hide_skill_panel() -> void:
	_skill_panel.clear()
	_skill_panel.visible = false


func get_action_menu_pos() -> Vector2:
	return _action_menu_pivot.position


func hide_action_menus() -> void:
	_action_menu_pivot.visible = false
	_skill_menu_pivot.visible = false


func _set_skills() -> void:
	for i in range(1, current_actor.stats.skills.size()):
		var index := i as int
		var skill := current_actor.stats.skills[index] as Skill
		var button := Button.new()
		button.icon = skill.icon
		# warning-ignore:return_value_discarded
		button.connect("pressed", self, "emit_signal",
				["skill_selected", index])
		_skill_menu.add_child(button)


func _clear_skills() -> void:
	for c in _skill_menu.get_children():
		var button := c as Control
		button.queue_free()


func _show_action_menu(menu_pivot: Node2D, screen_position: Vector2) \
		-> void:
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

	menu_pivot.visible = true
	menu_pivot.position = pivot_position


func _on_CurrentActorStatus_portrait_pressed() -> void:
	pass # Replace with function body.


func _on_Attack_pressed() -> void:
	emit_signal("skill_selected", 0)


func _on_Skill_pressed() -> void:
	_action_menu_pivot.visible = false
	show_skill_menu(_action_menu_pivot.position)


func _on_Wait_pressed() -> void:
	emit_signal("wait_started")


func _on_SkillPanel_cancelled() -> void:
	_skill_panel.visible = false
	emit_signal("skill_cleared")
