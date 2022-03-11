class_name ConditionIcons
extends Node2D


var _enabled_icons := []

var _icon_index := 0
var _visible_icon_index := 0

onready var _stat_mod_icons := $StatModIcons as Node2D

var _up_icons := {}
var _down_icons := {}


func _ready() -> void:
	for s in Constants.STAT_MODS:
		var stat_type := s as int
		var data := Constants.STAT_MODS[stat_type] as Dictionary

		var up = Sprite.new()
		up.texture = data.up as Texture

		var down = Sprite.new()
		down.texture = data.down as Texture

		_stat_mod_icons.add_child(up)
		_stat_mod_icons.add_child(down)

		_up_icons[stat_type] = up
		_down_icons[stat_type] = down


func update_icons(stats: Stats) -> void:
	_clear()

	_add_stat_mod_icon(stats, StatType.Type.MAX_STAMINA)
	_add_stat_mod_icon(stats, StatType.Type.ATTACK)
	_add_stat_mod_icon(stats, StatType.Type.DEFENCE)
	_add_stat_mod_icon(stats, StatType.Type.MOVE)
	_add_stat_mod_icon(stats, StatType.Type.SPEED)

	if _enabled_icons.size() > 0:
		var first_icon := _enabled_icons.front() as CanvasItem
		first_icon.visible = true


func _clear() -> void:
	_enabled_icons.clear()
	_visible_icon_index = 0

	for i in _stat_mod_icons.get_children():
		var icon := i as CanvasItem
		icon.visible = false


func _add_stat_mod_icon(stats: Stats, stat_type) -> void:
	var mod := stats.get_stat_mod(stat_type)
	if mod != 0:
		var icon: CanvasItem

		if mod > 0:
			icon = _up_icons[stat_type] as CanvasItem
		else:
			icon = _down_icons[stat_type] as CanvasItem

		_enabled_icons.append(icon)


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
