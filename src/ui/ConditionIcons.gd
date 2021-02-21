class_name ConditionIcons
extends Node2D


var _enabled_icons := []
var _visible_icon_index := 0

onready var _stat_mod_icons := $StatModIcons as Node2D

onready var _attack_up := _stat_mod_icons.get_node("AttackUp") as CanvasItem
onready var _attack_down := _stat_mod_icons.get_node("AttackDown") as CanvasItem
onready var _defence_up := _stat_mod_icons.get_node("DefenceUp") as CanvasItem
onready var _defence_down := _stat_mod_icons.get_node("DefenceDown") \
		as CanvasItem

onready var _timer := $Timer as Timer


func update_icons(stats: Stats) -> void:
	_clear()

	var attack_mod := stats.get_stat_mod(StatType.Type.ATTACK)
	_add_stat_mod_icon(_attack_up, _attack_down, attack_mod)

	var defence_mod := stats.get_stat_mod(StatType.Type.DAMAGE_REDUCTION)
	_add_stat_mod_icon(_defence_up, _defence_down, defence_mod)

	if _enabled_icons.size() > 0:
		var first_icon := _enabled_icons.front() as CanvasItem
		first_icon.visible = true
		_timer.start()


func _clear() -> void:
	_timer.stop()
	_enabled_icons.clear()
	_visible_icon_index = 0

	for i in _stat_mod_icons.get_children():
		var icon := i as CanvasItem
		icon.visible = false


func _add_stat_mod_icon(stat_up: CanvasItem, stat_down: CanvasItem,
		stat_mod: int) -> void:
	if stat_mod != 0:
		if stat_mod > 0:
			_enabled_icons.append(stat_up)
		else:
			_enabled_icons.append(stat_down)


func _on_Timer_timeout() -> void:
	if _enabled_icons.size() > 1:
		var old_icon := _enabled_icons[_visible_icon_index] as CanvasItem
		old_icon.visible = false

		_visible_icon_index = (_visible_icon_index + 1) % _enabled_icons.size()

		var new_icon := _enabled_icons[_visible_icon_index] as CanvasItem
		new_icon.visible = true
	else:
		assert(_enabled_icons.size() == 1)
		var icon := _enabled_icons.front() as CanvasItem
		icon.visible = not icon.visible
