class_name SkillDetails
extends PopupPanel

onready var _icon := $VBoxContainer/HBoxContainer/MarginContainer/Panel/Icon \
		as TextureRect
onready var _name := $VBoxContainer/HBoxContainer/VBoxContainer/Name as Label

onready var _cooldown := $VBoxContainer/HBoxContainer/VBoxContainer/ \
		HBoxContainer/Cooldown as Label
onready var _slash := $VBoxContainer/HBoxContainer/VBoxContainer/ \
		HBoxContainer/Slash as Control
onready var _max_cooldown := $VBoxContainer/HBoxContainer/VBoxContainer/ \
		HBoxContainer/MaxCooldown as Label

onready var _description := $VBoxContainer/MarginContainer/ScrollContainer/ \
		Description as Label


func show_skill(skill: Skill, show_current_cooldown := true) -> void:
	clear()
	_icon.texture = skill.icon
	_name.text = skill.skill_name

	_cooldown.visible = show_current_cooldown
	_slash.visible = show_current_cooldown

	if show_current_cooldown:
		_cooldown.text = str(skill.current_cooldown)

	_max_cooldown.text = str(skill.max_cooldown)

	_description.text = skill.description
	popup()


func clear() -> void:
	_icon.texture = null
	_name.text = ""
	_cooldown.text = ""
	_description.text = ""
