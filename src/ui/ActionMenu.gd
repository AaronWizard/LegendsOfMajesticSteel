class_name ActionMenu
extends Node2D

signal attack_pressed
signal wait_pressed

# warning-ignore:unused_signal
signal skill_selected(skill_index)

const _ROTATION_ONE_B := 90
const _ROTATION_TWO_B := 0
const _ROTATION_THREE_B := 90

onready var _actions := $Container/Actions as RadialContainer
onready var _skills := $Container/Skills as Control

onready var _attack_button := _actions.get_node("Attack") as Control
onready var _skills_button := _actions.get_node("Skill") as Control

onready var _animation := $AnimationPlayer as AnimationPlayer


func set_skills(skills: Array) -> void:
	_set_actions(skills)
	_set_skills(skills)


func clear_skills() -> void:
	for c in _skills.get_children():
		var button := c as Control
		button.queue_free()


func open() -> void:
	_animation.play("open_action_menu")


func close() -> void:
	_animation.play("close_menu")


func _set_actions(skills: Array) -> void:
	_attack_button.visible = skills.size() > 0
	_skills_button.visible = skills.size() > 1

	match skills.size():
		0:
			_actions.base_rotation = _ROTATION_ONE_B
		1:
			_actions.base_rotation = _ROTATION_TWO_B
		_:
			_actions.base_rotation = _ROTATION_THREE_B


func _set_skills(skills: Array) -> void:
	clear_skills()
	for i in range(1, skills.size()):
		var index := i as int
		var skill := skills[index] as Skill
		var button := Button.new()
		button.icon = skill.icon
		# warning-ignore:return_value_discarded
		button.connect("pressed", self, "emit_signal",
				["skill_selected", index])
		_skills.add_child(button)


func _on_Attack_pressed() -> void:
	if not _animation.is_playing():
		emit_signal("attack_pressed")


func _on_Skill_pressed() -> void:
	if not _animation.is_playing():
		_animation.play("open_skills_menu")


func _on_Wait_pressed() -> void:
	if not _animation.is_playing():
		emit_signal("wait_pressed")
