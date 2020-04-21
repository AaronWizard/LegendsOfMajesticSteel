class_name StaminaBar
extends Node2D

const MAX_STAMINA := 20

export(int, 0, 20) var current := MAX_STAMINA setget set_current
export var modifier := 0 setget set_modifier

onready var _cells := $Cells as Node

onready var _damage := $Damage as Node2D
onready var _healing := $Healing as Node2D

func set_current(value: int) -> void:
	current = value
	_update_cells()


func set_modifier(value: int) -> void:
	modifier = value
	_update_cells()


func _update_cells() -> void:
	if _cells:
		for c in _cells.get_children():
			var cell := c as Node2D
			cell.visible = cell.get_index() < current

	if _damage:
		if modifier < 0:
			var min_value := int(max(current + modifier, 0))
			var max_value := current
			_update_modifier_cells(_damage, min_value, max_value)
		else:
			_damage.visible = false

	if _healing:
		if modifier > 0:
			var min_value := current
			var max_value := int(min(current + modifier, MAX_STAMINA))
			_update_modifier_cells(_healing, min_value, max_value)
		else:
			_healing.visible = false


func _update_modifier_cells(modifier_cells: Node2D, min_value: int, max_value: int) -> void:
	modifier_cells.visible = true

	for c in modifier_cells.get_children():
		var cell := c as Node2D
		var index := cell.get_index() + 1
		cell.visible = (index > min_value) and (index <= max_value)
