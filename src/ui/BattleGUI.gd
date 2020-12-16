class_name BattleGUI
extends CanvasLayer

signal skill_selected(skill_index)
signal skill_cleared

signal wait_started

export var buttons_visible := false setget set_buttons_visible

var current_actor: Actor = null setget set_current_actor
var current_skill_index: int = -1 setget set_current_skill_index

onready var turn_queue := $TurnQueuePanel as TurnQueuePanel

onready var _current_actor_status := $CurrentActorStatus as ActorStatusPanel

onready var _all_buttons := $Buttons as Container
onready var _skill_buttons := $Buttons/Skills as Container

onready var _wait_button := $Buttons/Wait as Button
onready var _skill_cancel_button := $Buttons/SkillCancel as Button


func set_buttons_visible(value: bool) -> void:
	_all_buttons.visible = value


func set_current_actor(value: Actor) -> void:
	current_actor = value

	_clear_skill_buttons()
	_current_actor_status.clear()

	_current_actor_status.visible = current_actor != null

	if current_actor:
		_current_actor_status.set_actor(current_actor)
		_create_skill_buttons()


func set_current_skill_index(value: int) -> void:
	current_skill_index = value

	if current_skill_index > -1:
		_skill_buttons.visible = false
		_wait_button.visible = false
		_skill_cancel_button.visible = true
		emit_signal("skill_selected", current_skill_index)
	else:
		_skill_buttons.visible = true
		_wait_button.visible = true
		_skill_cancel_button.visible = false
		emit_signal("skill_cleared")


func _create_skill_buttons() -> void:
	for i in range(current_actor.stats.skills.size()):
		var index := i as int
		var skill := current_actor.stats.skills[index] as Skill

		var button := Button.new()
		button.text = skill.name
		# warning-ignore:return_value_discarded
		button.connect("pressed", self, "_on_skill_pressed", [index])
		_skill_buttons.add_child(button)


func _clear_skill_buttons() -> void:
	while _skill_buttons.get_child_count() > 0:
		var button := _skill_buttons.get_child(0)
		_skill_buttons.remove_child(button)
		button.disconnect("pressed", self, "_on_skill_pressed")
		button.queue_free()


func _on_skill_pressed(index: int) -> void:
	set_current_skill_index(index)


func _on_SkillCancel_pressed() -> void:
	set_current_skill_index(-1)


func _on_Wait_pressed() -> void:
	emit_signal("wait_started")


func _on_CurrentActorStatus_portrait_pressed() -> void:
	pass # Replace with function body.
