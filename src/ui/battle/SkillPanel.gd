class_name SkillPanel
extends Control

signal cancelled

onready var _skill_button := $Skill as Button

onready var _name := $PanelContainer/MarginContainer/VBoxContainer/Name as Label
onready var _no_valid_targets := $PanelContainer/MarginContainer/ \
		VBoxContainer/NoValidTargets as Control

onready var _details := $SkillDetails as SkillDetails

var _skill: Skill = null


func _ready() -> void:
	_details.visible = false


func set_skill(skill: Skill, no_valid_targets: bool) -> void:
	_skill_button.icon = skill.icon
	_name.text = skill.skill_name
	_no_valid_targets.visible = no_valid_targets
	_skill = skill


func clear() -> void:
	_skill_button.icon = null
	_name.text = ""
	_no_valid_targets.visible = false
	_skill = null


func _on_Skill_pressed() -> void:
	_details.show_skill(_skill, false)


func _on_Cancel_pressed() -> void:
	emit_signal("cancelled")
