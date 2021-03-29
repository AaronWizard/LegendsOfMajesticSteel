class_name SkillPanel
extends PanelContainer

signal cancelled


onready var _icon := $HBoxContainer/Icon as TextureRect
onready var _name := $HBoxContainer/Name as Label


func set_skill(skill: Skill) -> void:
	_icon.texture = skill.icon
	_name.text = skill.name


func clear() -> void:
	_icon.texture = null
	_name.text = ""


func _on_Cancel_pressed() -> void:
	emit_signal("cancelled")
