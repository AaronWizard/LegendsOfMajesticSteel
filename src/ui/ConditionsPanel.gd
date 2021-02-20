tool
class_name ConditionsPanel
extends HBoxContainer

enum StatMod { SAME, UP, DOWN }

export(StatMod) var attack_mod: int = StatMod.SAME setget set_attack_mod
export(StatMod) var defence_mod: int = StatMod.SAME setget set_defence_mod

onready var _attack_up := $AttackUp as Control
onready var _attack_down := $AttackDown as Control
onready var _defence_up := $DefenceUp as Control
onready var _defence_down := $DefenceDown as Control


func set_attack_mod(value: int) -> void:
	attack_mod = value
	_show_icon(_attack_up, _attack_down, attack_mod)


func set_defence_mod(value: int) -> void:
	defence_mod = value
	_show_icon(_defence_up, _defence_down, defence_mod)


func _show_icon(icon_up: Control, icon_down: Control, mod: int) -> void:
	if icon_up and icon_down:
		match mod:
			StatMod.UP:
				icon_up.visible = true
				icon_down.visible = false
			StatMod.DOWN:
				icon_up.visible = false
				icon_down.visible = true
			_:
				icon_up.visible = false
				icon_down.visible = false
