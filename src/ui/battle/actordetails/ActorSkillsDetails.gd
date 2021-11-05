class_name ActorSkillsDetails
extends ReferenceRect

var _skill_button_scene := preload( \
		"res://src/ui/battle/actordetails/ActorSkillDetailsSkillButton.tscn" \
		)  as PackedScene

const _READY_TEXT := "Ready!"

const _SKILLS_INDEX := 0
const _NO_SKILLS_INDEX := 1

onready var _tabs := $TabContainer as TabContainer
onready var _skills := _tabs.get_node("Skills")

onready var _skill_popup_position := $SkillDetailsPosition as Position2D
onready var _skill_popup := $SkillDetails as SkillDetails


func _ready() -> void:
	_skill_popup.visible = false


func set_skills(skills: Array) -> void:
	clear()

	if skills.empty():
		_tabs.current_tab = _NO_SKILLS_INDEX
	else:
		_tabs.current_tab = _SKILLS_INDEX

		for s in skills:
			var skill := s as Skill

			var skill_button := _skill_button_scene.instance() \
					as ActorSkillDetailsSkillButton
			_skills.add_child(skill_button)

			skill_button.icon = skill.icon

			var cooldown := skill.current_cooldown
			if cooldown > 0:
				skill_button.cooldown.text = str(cooldown)
			else:
				skill_button.cooldown.text = _READY_TEXT

			# warning-ignore:return_value_discarded
			skill_button.connect("pressed", self, "_skill_pressed", [skill])


func clear() -> void:
	for b in _skills.get_children():
		var skill_button := b as Node
		_skills.remove_child(skill_button)
		skill_button.queue_free()


func _skill_pressed(skill: Skill) -> void:
	_skill_popup.set_position(_skill_popup_position.global_position)
	_skill_popup.show_skill(skill)
