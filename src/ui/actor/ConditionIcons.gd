class_name ConditionIcons
extends Node2D


var _enabled_icons := []

var _icon_index := 0
var _visible_icon_index := 0

onready var _stat_mod_icons := $StatModIcons as Node2D

onready var _attack_up := _stat_mod_icons.get_node("AttackUp") as CanvasItem
onready var _attack_down := _stat_mod_icons.get_node("AttackDown") as CanvasItem
onready var _defence_up := _stat_mod_icons.get_node("DefenceUp") as CanvasItem
onready var _defence_down := _stat_mod_icons.get_node("DefenceDown") \
		as CanvasItem
onready var _move_up := _stat_mod_icons.get_node("MoveUp") as CanvasItem
onready var _move_down := _stat_mod_icons.get_node("MoveDown") as CanvasItem


func update_icons(stats: Stats) -> void:
	_clear()

	_add_stat_mod_icon(stats, StatType.Type.ATTACK, _attack_up, _attack_down)
	_add_stat_mod_icon(stats, StatType.Type.DEFENCE,
			_defence_up, _defence_down)
	_add_stat_mod_icon(stats, StatType.Type.MOVE, _move_up, _move_down)

	if _enabled_icons.size() > 0:
		var first_icon := _enabled_icons.front() as CanvasItem
		first_icon.visible = true


func _clear() -> void:
	_enabled_icons.clear()
	_visible_icon_index = 0

	for i in _stat_mod_icons.get_children():
		var icon := i as CanvasItem
		icon.visible = false


func _add_stat_mod_icon(stats: Stats, stat_type: int,
		stat_up: CanvasItem, stat_down: CanvasItem) -> void:
	var mod := stats.get_stat_mod(stat_type)
	if mod != 0:
		if mod > 0:
			_enabled_icons.append(stat_up)
		else:
			_enabled_icons.append(stat_down)


func _on_Timer_timeout() -> void:
	_icon_index = (_icon_index + 1) % _stat_mod_icons.get_child_count()

	if not _enabled_icons.empty():
		if _enabled_icons.size() > 1:
			var old_icon := _enabled_icons[_visible_icon_index] as CanvasItem
			old_icon.visible = false

			_visible_icon_index = _icon_index % _enabled_icons.size()

			var new_icon := _enabled_icons[_visible_icon_index] as CanvasItem
			new_icon.visible = true
		else:
			var icon := _enabled_icons.front() as CanvasItem
			icon.visible = (_icon_index % 2) == 0
