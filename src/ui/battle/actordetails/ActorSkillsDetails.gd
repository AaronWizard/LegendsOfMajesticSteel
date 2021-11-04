class_name ActorSkillsDetails
extends TabContainer

var _skill_button_scene := preload( \
		"res://src/ui/battle/actordetails/ActorSkillDetailsSkillButton.tscn" \
		)  as PackedScene

const _READY_TEXT := "Ready!"

onready var _no_skills_info := $NoSkillsInfo as Control
onready var _skill_info := $SkillInfo as Control

onready var _skills := _skill_info.get_node("SkillsContainer/Skills") as Control
onready var _current_skill_border := \
		_skill_info.get_node("SkillsContainer/CurrentSkillBorder") as Control

onready var _skill_data := \
		_skill_info.get_node("SkillInfoMargin/VBoxContainer") as Control
onready var _skill_name := _skill_data.get_node("HBoxContainer/SkillName") \
		 as Label
onready var _cooldown := _skill_data.get_node("HBoxContainer/Cooldown") \
		as Label
onready var _skill_description := _skill_data.get_node("SkillDescription") \
		as Label


func set_skills(skills: Array) -> void:
	clear()

	if skills.empty():
		current_tab = _no_skills_info.get_index()
	else:
		current_tab = _skill_info.get_index()

		for i in range(skills.size()):
			var index := i as int
			var skill := skills[index] as Skill

			var skill_button := _skill_button_scene.instance() \
					as ActorSkillDetailsSkillButton
			_skills.add_child(skill_button)

			skill_button.button.icon = skill.icon

			var cooldown := skill.current_cooldown
			if cooldown > 0:
				skill_button.cooldown.text = str(cooldown)
			else:
				skill_button.cooldown.text = _READY_TEXT

			# warning-ignore:return_value_discarded
			skill_button.button.connect("pressed", self, "_skill_pressed", [
				index, skill.skill_name, skill.max_cooldown, skill.description
			])

			if index == 0:
				_skill_pressed(index, skill.skill_name, skill.max_cooldown,
						skill.description)


func clear() -> void:
	_current_skill_border.rect_position = Vector2.ZERO
	for b in _skills.get_children():
		var skill_button := b as Node
		_skills.remove_child(skill_button)
		skill_button.queue_free()


func _skill_pressed(index: int, skill_name: String, cooldown: int,
		description: String) -> void:
	var skill_button := _skills.get_child(index) as Control
	_current_skill_border.rect_position = skill_button.rect_position

	_skill_name.text = skill_name
	_cooldown.text = str(cooldown)
	_skill_description.text = description
