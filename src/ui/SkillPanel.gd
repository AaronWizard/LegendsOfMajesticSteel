class_name SkillPanel
extends PanelContainer

signal cancelled


onready var _icon := $HBoxContainer/MarginContainer/VBoxContainer/ \
		HBoxContainer/Icon as TextureRect
onready var _name := $HBoxContainer/MarginContainer/VBoxContainer/ \
		HBoxContainer/Name as Label
onready var _description := $HBoxContainer/MarginContainer/ \
		VBoxContainer/Description as Label


func set_skill(skill: Skill) -> void:
	_icon.texture = skill.icon
	_name.text = skill.name
	_description.text = skill.description


func clear() -> void:
	_icon.texture = null
	_name.text = ""
	_description.text = ""


func _on_Cancel_pressed() -> void:
	emit_signal("cancelled")
