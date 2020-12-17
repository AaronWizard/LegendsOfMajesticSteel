class_name BattleGUI
extends CanvasLayer

signal attack_selected
signal wait_started

var current_actor: Actor = null setget set_current_actor

onready var turn_queue := $TurnQueuePanel as TurnQueuePanel

onready var _current_actor_status := $CurrentActorStatus as ActorStatusPanel

onready var _action_menu_pivot := $ActionMenuPivot as Control


func set_current_actor(value: Actor) -> void:
	current_actor = value
	_current_actor_status.clear()

	_current_actor_status.visible = current_actor != null

	if current_actor:
		_current_actor_status.set_actor(current_actor)


func show_action_menu(position: Vector2) -> void:
	_action_menu_pivot.visible = true
	_action_menu_pivot.rect_position = position


func hide_action_menu() -> void:
	_action_menu_pivot.visible = false


func _on_CurrentActorStatus_portrait_pressed() -> void:
	pass # Replace with function body.


func _on_Attack_pressed() -> void:
	emit_signal("attack_selected")


func _on_Skill_pressed() -> void:
	pass # Replace with function body.


func _on_Wait_pressed() -> void:
	emit_signal("wait_started")
