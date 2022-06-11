class_name ActorStatusEffectDetails
extends TabContainer

var _single_condition_details_scene := preload( \
		"res://src/ui/battle/actordetails/SingleStatusEffectDetails.tscn" \
		) as PackedScene

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

	for k in stat_mods:
		var key := k as Vector3

		var stat_type := int(key.x)
		var rounds := int(key.z)
		var modifier := stat_mods[key] as float
		_show_single_stat_mod(stat_type, modifier, rounds)


func _show_single_stat_mod(stat_type: int, mod: float, rounds_left: int) \
		-> void:
	var condition_info := _single_condition_details_scene.instance() \
			as SingleStatusEffectDetails
	_list.add_child(condition_info)

	var stat_ui_data := Constants.STAT_MODS[stat_type] as Dictionary

	var icon: Texture
	if mod > 0:
		icon = stat_ui_data.up as Texture
	else:
		icon = stat_ui_data.down as Texture
	condition_info.set_condition_icon(icon)

	var name := stat_ui_data.name as String
	condition_info.set_condition_name(name)

	condition_info.set_magnitude(mod)
	if rounds_left > -1:
		condition_info.show_rounds_left(rounds_left)
	else:
		condition_info.hide_rounds_left()
