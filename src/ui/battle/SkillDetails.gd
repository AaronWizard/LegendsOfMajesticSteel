class_name SkillDetails
extends PopupPanel

onready var _icon := $VBoxContainer/HBoxContainer/MarginContainer/Panel/Icon \
		as TextureRect
onready var _name := $VBoxContainer/HBoxContainer/VBoxContainer/Name as Label
onready var _cooldown := $VBoxContainer/HBoxContainer/VBoxContainer/ \
		HBoxContainer/Cooldown as Label
onready var _max_cooldown := $VBoxContainer/HBoxContainer/VBoxContainer/ \
		HBoxContainer/MaxCooldown as Label
onready var _description := $VBoxContainer/MarginContainer/ScrollContainer/ \
		Description as Label


func show_skill(skill: Skill) -> void:
	clear()
	_icon.texture = skill.icon
	_name.text = skill.skill_name
	_cooldown.text = str(skill.current_cooldown)
	_max_cooldown.text = str(skill.max_cooldown)
	_description.text = skill.description
	popup_centered()


func clear() -> void:
	_icon.texture = null
	_name.text = ""
	_cooldown.text = ""
	_description.text = ""
