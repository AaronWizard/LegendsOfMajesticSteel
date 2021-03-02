class_name SkillMenu
extends Node2D

# warning-ignore:unused_signal
signal skill_selected(skill_index)

onready var _container := $RadialContainer as RadialContainer


func set_skills(skills: Array) -> void:
	for i in range(1, skills.size()):
		var index := i as int
		var skill := skills[index] as Skill
		var button := Button.new()
		button.icon = skill.icon
		# warning-ignore:return_value_discarded
		button.connect("pressed", self, "emit_signal",
				["skill_selected", index])
		_container.add_child(button)


func clear_skills() -> void:
	for c in _container.get_children():
		var button := c as Control
		button.queue_free()
