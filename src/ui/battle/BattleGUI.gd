class_name BattleGUI
extends CanvasLayer

signal attack_selected
signal skill_selected(skill_index)
signal wait_selected

signal skill_cleared

var current_actor: Actor = null setget set_current_actor
var other_actor: Actor = null setget set_other_actor

var action_menu_position: Vector2 setget \
		set_action_menu_pos, get_action_menu_pos
var action_menu_open: bool setget , get_action_menu_open

onready var turn_panel := ($BorderedTurnPanel as BorderedTurnPanel).turn_panel

onready var _current_actor_status := $CurrentActorStatus as ActorStatusPanel
onready var _other_actor_status := $OtherActorStatus as ActorStatusPanel

onready var _actor_details := $ActorDetailsPanel as ActorDetailsPanel

onready var _action_menu_region := $ActionMenuRegion as Control
onready var _action_menu := $ActionMenu as ActionMenu
onready var _skill_panel := $SkillPanel as SkillPanel

onready var _options_panel := $GameOptionsPanel as Popup


func _ready() -> void:
	_current_actor_status.visible = false
	_other_actor_status.visible = false
	_skill_panel.visible = false

	# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")


func set_current_actor(value: Actor) -> void:
	current_actor = value

	var portrait_clickable := (current_actor != null) \
			and (current_actor.faction == (Actor.Faction.PLAYER as int))
	_set_actor(
		current_actor, _current_actor_status, portrait_clickable
	)

	if current_actor:
		_action_menu.set_actions(
				current_actor.attack_skill, current_actor.skills)
	else:
		_action_menu.clear_skills()


func set_other_actor(value: Actor) -> void:
	if other_actor:
		other_actor.other_target_visible = false
	other_actor = value
	_set_actor(other_actor, _other_actor_status, true)
	if other_actor:
		other_actor.other_target_visible = true
		turn_panel.select_other_actor(other_actor.get_index())
	else:
		turn_panel.clear_other_actor()


func set_action_menu_pos(value: Vector2) -> void:
	var rect := _action_menu_region.get_rect()
	var pivot_position := value

	if not rect.has_point(pivot_position):
		if pivot_position.x > rect.end.x:
			pivot_position.x = rect.end.x
		elif pivot_position.x < rect.position.x:
			pivot_position.x = rect.position.x

		if pivot_position.y < rect.position.y:
			pivot_position.y = rect.position.y
		elif pivot_position.y > rect.end.y:
			pivot_position.y = rect.end.y

	_action_menu.position = pivot_position


func get_action_menu_pos() -> Vector2:
	return _action_menu.position


func get_action_menu_open() -> bool:
	return _action_menu.is_open


func open_action_menu() -> void:
	yield(_action_menu.open(), "completed")


func close_action_menu(with_sound := true) -> void:
	yield(_action_menu.close(with_sound), "completed")


func show_skill_panel(skill: Skill, no_valid_targets: bool) -> void:
	_skill_panel.set_skill(skill, no_valid_targets)
	_skill_panel.visible = true


func hide_skill_panel() -> void:
	_skill_panel.clear()
	_skill_panel.visible = false


static func _set_actor(actor: Actor, actor_status: ActorStatusPanel,
			portrait_clickable: bool) -> void:
	actor_status.visible = actor != null

	if actor:
		actor_status.set_actor(actor, portrait_clickable)
	else:
		actor_status.clear()


func _show_actor_details(actor: Actor) -> void:
	_actor_details.set_actor(actor)
	_actor_details.popup_centered()


func _on_CurrentActorStatus_portrait_pressed() -> void:
	_show_actor_details(current_actor)


func _on_OtherActorStatus_portrait_pressed() -> void:
	_show_actor_details(other_actor)


func _on_SkillPanel_cancelled() -> void:
	_skill_panel.visible = false
	emit_signal("skill_cleared")


func _on_ActionMenu_attack_selected() -> void:
	emit_signal("attack_selected")


func _on_ActionMenu_wait_selected() -> void:
	emit_signal("wait_selected")


func _on_ActionMenu_skill_selected(skill_index: int) -> void:
	emit_signal("skill_selected", skill_index)


func _on_size_changed() -> void:
	if _actor_details.visible:
		_actor_details.anchor_left = 0.5
		_actor_details.anchor_right = 0.5
		_actor_details.anchor_top = 0.5
		_actor_details.anchor_bottom = 0.5


func _on_OptionsButton_pressed() -> void:
	_options_panel.popup_centered()
