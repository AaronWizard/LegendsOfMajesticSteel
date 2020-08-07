class_name BattleGUI
extends CanvasLayer

signal ability_selected(ability)
signal ability_cleared

signal wait_started

var buttons_visible := false setget set_buttons_visible

var current_actor: Actor = null setget set_current_actor

var current_ability: Ability = null setget set_current_ability

onready var turn_queue := $TurnQueuePanel as TurnQueuePanel

onready var _current_actor_portrait := $CurrentActorPortraitButton as Button

onready var _all_buttons := $Buttons as Container
onready var _ability_buttons := $Buttons/Abilities as Container

onready var _wait_button := $Buttons/Wait as Button
onready var _ability_cancel_button := $Buttons/AbilityCancel as Button


func set_buttons_visible(value: bool) -> void:
	_all_buttons.visible = value


func set_current_actor(value: Actor) -> void:
	current_actor = value

	_clear_ability_buttons()
	_current_actor_portrait.icon = null

	_current_actor_portrait.disabled = current_actor == null

	if current_actor:
		_create_ability_buttons()
		_current_actor_portrait.icon = current_actor.portrait


func set_current_ability(value: Ability) -> void:
	current_ability = value

	if current_ability:
		_ability_buttons.visible = false
		_wait_button.visible = false
		_ability_cancel_button.visible = true
		emit_signal("ability_selected", current_ability)
	else:
		_ability_buttons.visible = true
		_wait_button.visible = true
		_ability_cancel_button.visible = false
		emit_signal("ability_cleared")


func _create_ability_buttons() -> void:
	for a in current_actor.get_abilities():
		var ability := a as Ability
		var button := Button.new()
		button.text = ability.name
		# warning-ignore:return_value_discarded
		button.connect("pressed", self, "_on_ability_pressed", [ability])
		_ability_buttons.add_child(button)


func _clear_ability_buttons() -> void:
	while _ability_buttons.get_child_count() > 0:
		var button := _ability_buttons.get_child(0)
		_ability_buttons.remove_child(button)
		button.disconnect("pressed", self, "_on_ability_pressed")
		button.queue_free()


func _on_ability_pressed(ability: Ability) -> void:
	set_current_ability(ability)


func _on_AbilityCancel_pressed() -> void:
	set_current_ability(null)


func _on_Wait_pressed() -> void:
	emit_signal("wait_started")


func _on_CurrentActorPortraitButton_pressed() -> void:
	pass # Replace with function body.
