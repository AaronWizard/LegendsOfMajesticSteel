class_name ActionMenu
extends Node2D

signal attack_pressed
signal wait_pressed

# warning-ignore:unused_signal
signal skill_selected(skill_index)

const _ROTATION_ONE_B := 90
const _ROTATION_TWO_B := 0
const _ROTATION_THREE_B := 90

var is_open: bool setget , get_is_open

var _is_open := false

onready var _actions := $Container/Actions as RadialContainer
onready var _skills := $Container/Skills as Control

onready var _attack_button := _actions.get_node("Attack") as Control
onready var _skills_button := _actions.get_node("Skill") as Control

onready var _animation := $AnimationPlayer as AnimationPlayer

onready var _close_sound := $CloseSound as AudioStreamPlayer


func get_is_open() -> bool:
	return _is_open


func set_skills(skills: Array, energy: int) -> void:
	_set_skills(skills, energy)
	_set_actions(skills)


func clear_skills() -> void:
	for c in _skills.get_children():
		var button := c as Control
		button.queue_free()


func open() -> void:
	_is_open = true
	_animation.play("open_action_menu")


func close(with_sound := true) -> void:
	_is_open = false
	if with_sound:
		_close_sound.play()
	_animation.play("close_menu")


func _set_skills(skills: Array, energy: int) -> void:
	clear_skills()
	for i in range(1, skills.size()):
		var index := i as int
		var skill := skills[index] as Skill
		if energy >= skill.energy_cost:
			var button := Constants.create_sound_button()
			button.icon = skill.icon
			# warning-ignore:return_value_discarded
			button.connect("pressed", self, "emit_signal",
					["skill_selected", index])
			_skills.add_child(button)


func _set_actions(skills: Array) -> void:
	_attack_button.visible = skills.size() > 0
	_skills_button.visible = _skills.get_child_count() > 0

	match [_attack_button.visible, _skills_button.visible]:
		[false, false]:
			_actions.base_rotation = _ROTATION_ONE_B
		[true, false]:
			_actions.base_rotation = _ROTATION_TWO_B
		_:
			_actions.base_rotation = _ROTATION_THREE_B


func _on_Attack_pressed() -> void:
	if not _animation.is_playing():
		emit_signal("attack_pressed")


func _on_Skill_pressed() -> void:
	if not _animation.is_playing():
		_animation.play("open_skills_menu")


func _on_Wait_pressed() -> void:
	if not _animation.is_playing():
		emit_signal("wait_pressed")
