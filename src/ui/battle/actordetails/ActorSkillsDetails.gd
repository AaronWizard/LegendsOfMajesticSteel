class_name ActorSkillsDetails
extends VBoxContainer

var _skill_button_scene := preload( \
		"res://src/ui/battle/actordetails/ActorSkillDetailsSkillButton.tscn" \
		)  as PackedScene

onready var _no_skills_info := $NoSkillsInfo as Control

onready var _skills := $SkillInfo/SkillsContainer/Skills as Control
onready var _current_skill_border := $SkillInfo/SkillsContainer/ \
		CurrentSkillBorder as Control

onready var _skill_info := $SkillInfo/SkillInfoMargin/VBoxContainer as Control
onready var _skill_name := _skill_info.get_node("HBoxContainer/SkillName") \
		 as Label
onready var _energy_cost := _skill_info.get_node("HBoxContainer/EnergyCost") \
		as Label
onready var _skill_description := _skill_info.get_node("SkillDescription") \
		as Label


func set_skills(skills: Array, current_actor_energy: int) -> void:
	clear()

	if skills.empty():
		_skill_info.visible = false
		_no_skills_info.visible = true
	else:
		_no_skills_info.visible = false
		_skill_info.visible = true

		for i in range(skills.size()):
			var index := i as int
			var skill := skills[index] as Skill

			var skill_button := _skill_button_scene.instance() \
					as ActorSkillDetailsSkillButton
			_skills.add_child(skill_button)

			skill_button.button.icon = skill.icon

			var cooldown := skill.energy_cost - current_actor_energy
			if cooldown > 0:
				skill_button.cooldown.text = str(cooldown)
			else:
				skill_button.cooldown.text = ""

			# warning-ignore:return_value_discarded
			skill_button.button.connect("pressed", self, "_skill_pressed", [
				index, skill.skill_name,
				skill.energy_cost, skill.description
			])

			if index == 0:
				_skill_pressed(index, skill.skill_name, skill.energy_cost,
						skill.description)


func clear() -> void:
	_current_skill_border.rect_position = Vector2.ZERO
	for b in _skills.get_children():
		var skill_button := b as Node
		_skills.remove_child(skill_button)
		skill_button.queue_free()


func _skill_pressed(index: int, skill_name: String, energy_cost: int,
		description: String) -> void:
	var skill_button := _skills.get_child(index) as Control
	_current_skill_border.rect_position = skill_button.rect_position

	_skill_name.text = skill_name
	_energy_cost.text = str(energy_cost)
	_skill_description.text = description
