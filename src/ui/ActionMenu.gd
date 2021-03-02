class_name ActionMenu
extends Node2D

signal attack_pressed
signal skill_pressed
signal wait_pressed

const _ROTATION_ONE_B := 90
const _ROTATION_TWO_B := 0
const _ROTATION_THREE_B := 90

onready var _container := $RadialContainer as RadialContainer

onready var _attack_button := $RadialContainer/Attack as Control
onready var _skills_button := $RadialContainer/Skill as Control


func set_skills(skills: Array) -> void:
	_attack_button.visible = skills.size() > 0
	_skills_button.visible = skills.size() > 1

	match skills.size():
		0:
			_container.base_rotation = _ROTATION_ONE_B
		1:
			_container.base_rotation = _ROTATION_TWO_B
		_:
			_container.base_rotation = _ROTATION_THREE_B


func _on_Attack_pressed() -> void:
	emit_signal("attack_pressed")


func _on_Skill_pressed() -> void:
	emit_signal("skill_pressed")


func _on_Wait_pressed() -> void:
	emit_signal("wait_pressed")
