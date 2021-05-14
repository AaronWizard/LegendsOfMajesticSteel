class_name SkillPanel
extends PanelContainer

signal cancelled


onready var _icon := $HBoxContainer/Icon as TextureRect
onready var _name := $HBoxContainer/VBoxContainer/Name as Label
onready var _no_valid_targets := $HBoxContainer/VBoxContainer/NoValidTargets \
		as Control


func set_skill(skill: Skill, no_valid_targets: bool) -> void:
	_icon.texture = skill.icon
	_name.text = skill.skill_name
	_no_valid_targets.visible = no_valid_targets


func clear() -> void:
	_icon.texture = null
	_name.text = ""
	_no_valid_targets.visible = false


func _on_Cancel_pressed() -> void:
	emit_signal("cancelled")
