class_name ConditionsPanel
extends HBoxContainer

onready var _attack_up := $AttackUp as Control
onready var _attack_down := $AttackDown as Control
onready var _defence_up := $DefenceUp as Control
onready var _defence_down := $DefenceDown as Control
onready var _move_up := $MoveUp as Control
onready var _move_down := $MoveDown as Control


func update_icons(stats: Stats) -> void:
	_show_icon(stats, StatType.Type.ATTACK, _attack_up, _attack_down)
	_show_icon(stats, StatType.Type.DAMAGE_REDUCTION, _defence_up,
			_defence_down)
	_show_icon(stats, StatType.Type.MOVE, _move_up, _move_down)


func _show_icon(stats: Stats, stat_type: int, icon_up: Control,
		icon_down: Control) -> void:
	var mod := stats.get_stat_mod(stat_type)
	if mod > 0:
		icon_up.visible = true
		icon_down.visible = false
	elif mod < 0:
		icon_up.visible = false
		icon_down.visible = true
	else:
		icon_up.visible = false
		icon_down.visible = false
