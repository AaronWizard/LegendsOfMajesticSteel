class_name ActorDetailsPanel
extends PanelContainer

signal closed

onready var _portrait := $Main/Header/PortraitMargin/PortraitBorder/Portrait \
		as TextureRect
onready var _name := $Main/Header/HeaderInfoMargin/VBoxContainer/Name as Label

onready var _stamina_info := $Main/Header/HeaderInfoMargin/VBoxContainer/ \
		Stamina as Control
onready var _current_stamina := _stamina_info.get_node("CurrentStamina") \
		as Label
onready var _max_stamina := _stamina_info.get_node("MaxStamina") as Label

onready var _stats := $Main/StatsPanel/MarginContainer/Stats as Control
onready var _attack := _stats.get_node("AttackInfo") as ActorStatDetails
onready var _move := _stats.get_node("MoveInfo") as ActorStatDetails

onready var _skills := $Main/SkillsContainer/Skills as ActorSkillsDetails
onready var _conditions := $Main/ConditionsContainer/Conditions \
		as ActorConditionDetails


func set_actor(actor: Actor) -> void:
	clear()

	_portrait.texture = actor.portrait
	_name.text = actor.character_name

	_current_stamina.text = str(actor.stats.stamina)
	_max_stamina.text = str(actor.stats.max_stamina)

	_attack.set_stat_values(actor.stats, StatType.Type.ATTACK)
	_move.set_stat_values(actor.stats, StatType.Type.MOVE)

	_skills.set_skills(actor.skills)
	_conditions.set_conditions(actor)


func clear() -> void:
	_portrait.texture = null
	_skills.clear()
	_conditions.clear()


func _on_TabContainer_tab_changed(_tab: int) -> void:
	StandardSounds.play_select()


func _on_Close_pressed() -> void:
	emit_signal("closed")
