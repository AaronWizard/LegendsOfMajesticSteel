class_name ActorDetailsPanel
extends PanelContainer

var _stat_icons := {
	StatType.Type.ATTACK: {
		name = "Attack",
		up = preload( \
				"res://assets/graphics/ui/icons/conditions/attack_up.png") \
				as Texture,
		down = preload( \
				"res://assets/graphics/ui/icons/conditions/attack_down.png") \
				as Texture
	},
	StatType.Type.DAMAGE_REDUCTION: {
		name = "Defence",
		up = preload( \
				"res://assets/graphics/ui/icons/conditions/defence_up.png") \
				as Texture,
		down = preload( \
				"res://assets/graphics/ui/icons/conditions/defence_down.png") \
				as Texture
	},
	StatType.Type.MOVE: {
		name = "Move",
		up = preload( \
				"res://assets/graphics/ui/icons/conditions/move_up.png") \
				as Texture,
		down = preload( \
				"res://assets/graphics/ui/icons/conditions/move_down.png") \
				as Texture
	}
}

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

	_set_conditions(actor)


func clear() -> void:
	_portrait.texture = null

	for c in _conditions.get_children():
		var control := c as Control
		control.queue_free()


func _set_stamina(actor: Actor) -> void:
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
		stat_mod_label.text = _format_mod_str(stat_mod)


func _set_conditions(actor: Actor) -> void:
	var stat_mods := actor.stats.get_condition_stat_mods()
	for s in stat_mods:
		var stat_id := s as int
		var modifier_data := stat_mods[stat_id] as Dictionary
		for m in modifier_data:
			var rounds := m as int
			var modifier := modifier_data[rounds] as int

			_show_stat_modifier(stat_id, modifier, rounds)


func _show_stat_modifier(stat_type: int, mod: int, rounds_left) -> void:
	if mod != 0:
		var stat_ui_data := _stat_icons[stat_type] as Dictionary

		var icon := TextureRect.new()
		if mod > 0:
			icon.texture = stat_ui_data.up as Texture
		else:
			icon.texture = stat_ui_data.down as Texture
		_conditions.add_child(icon)

		var stat_name_label := Label.new()
		stat_name_label.text = stat_ui_data.name as String
		_conditions.add_child(stat_name_label)

		var mod_label := Label.new()
		mod_label.text = _format_mod_str(mod)
		if stat_type == StatType.Type.DAMAGE_REDUCTION:
			mod_label.text += "%"
		_conditions.add_child(mod_label)

		if rounds_left > -1:
			var rounds_label := Label.new()
			rounds_label.text = "%s rounds" % str(rounds_left)
			_conditions.add_child(rounds_label)
		else:
			var rounds_space := Control.new()
			_conditions.add_child(rounds_space)


static func _format_mod_str(mod: int) -> String:
	var result: String

	if mod > 0:
		result = "+%s" % mod
	else:
		result = str(mod)

	return result
