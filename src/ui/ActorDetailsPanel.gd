class_name ActorDetailsPanel
extends PanelContainer


onready var _portrait := $Container/Header/PortraitContainer/Portrait \
		as TextureRect
onready var _name := $Container/Header/VBoxContainer/Name as Label

onready var _stamina := $Container/Header/VBoxContainer/StaminaValues as Node
onready var _current_stamina := _stamina.get_node("CurrentStamina") as Label
onready var _max_stamina := _stamina.get_node("MaxStamina") as Label

onready var _stats := $Container/Stats as Node
onready var _stat_rows := {
	StatType.Type.ATTACK: {
		value = _stats.get_node("AttackValue"),
		mod = _stats.get_node("AttackMod")
	},
	StatType.Type.MOVE: {
		value = _stats.get_node("MoveValue"),
		mod = _stats.get_node("MoveMod")
	}
}

onready var _conditions := $Container/ConditionsScroll/ConditionsGrid as Node


func set_actor(actor: Actor) -> void:
	clear()

	_portrait.texture = actor.portrait
	_name.text = actor.character_name
	_set_stamina(actor)

	_set_stats(actor, StatType.Type.ATTACK)
	_set_stats(actor, StatType.Type.MOVE)


func clear() -> void:
	_portrait.texture = null

	for c in _conditions.get_children():
		var control := c as Control
		control.queue_free()


func _set_stamina(actor:Actor) -> void:
	_current_stamina.text = str(actor.stats.stamina)
	_max_stamina.text = str(actor.stats.max_stamina)


func _set_stats(actor: Actor, stat_type: int) -> void:
	var stat_value := actor.stats.get_stat(stat_type)
	var stat_mod := actor.stats.get_stat_mod(stat_type)

	var stat_row := _stat_rows[stat_type] as Dictionary

	var stat_value_label := stat_row.value as Label
	stat_value_label.text = str(stat_value)

	var stat_mod_label := stat_row.mod as Label
	if stat_mod == 0:
		stat_mod_label.text = ""
	else:
		stat_mod_label.text = "(%s)" % str(stat_mod)
