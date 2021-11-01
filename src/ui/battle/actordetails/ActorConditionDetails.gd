class_name ActorConditionDetails
extends TabContainer

var _single_condition_details_scene := preload( \
		"res://src/ui/battle/actordetails/SingleConditionDetails.tscn" \
		) as PackedScene

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
	StatType.Type.DEFENCE: {
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

onready var _no_conditions_container := $NoConditionsContainer as Control
onready var _conditions_container := $ConditionsContainer as Control

onready var _list := _conditions_container.get_node("Scroll/ConditionList") \
		 as Control


func set_conditions(actor: Actor) -> void:
	clear()
	_show_stat_mods(actor)

	if _list.get_child_count() > 0:
		current_tab = _conditions_container.get_index()
	else:
		current_tab = _no_conditions_container.get_index()


func clear() -> void:
	for c in _list.get_children():
		var condition_info := c as Control
		_list.remove_child(condition_info)
		condition_info.queue_free()


func _show_stat_mods(actor: Actor) -> void:
	var stat_mods := actor.stats.get_condition_stat_mods()

	for s in stat_mods:
		var stat_id := s as int
		var modifier_data := stat_mods[stat_id] as Dictionary
		for m in modifier_data:
			var rounds := m as int
			var modifier := modifier_data[rounds] as int
			_show_single_stat_mod(stat_id, modifier, rounds)


func _show_single_stat_mod(stat_type: int, mod: int, rounds_left: int) -> void:
	var condition_info := _single_condition_details_scene.instance() \
			as SingleConditionDetails
	_list.add_child(condition_info)

	var stat_ui_data := _stat_icons[stat_type] as Dictionary

	var icon: Texture
	if mod > 0:
		icon = stat_ui_data.up as Texture
	else:
		icon = stat_ui_data.down as Texture
	condition_info.set_condition_icon(icon)

	var name := stat_ui_data.name as String
	condition_info.set_condition_name(name)

	condition_info.set_magnitude(mod, stat_type == StatType.Type.DEFENCE)
	if rounds_left > -1:
		condition_info.show_rounds_left(rounds_left)
	else:
		condition_info.hide_rounds_left()
