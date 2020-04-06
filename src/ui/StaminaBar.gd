tool
extends Node2D

enum _CellState { STAMINA, DAMAGE, HEAL }

export(int, 0, 20) var current := 20 setget set_current
export var modifier := 0 setget set_modifier

onready var _cells := $Cells as Node

func set_current(value: int) -> void:
	current = value
	_update_cells()

func set_modifier(value: int) -> void:
	modifier = value
	_update_cells()

func _update_cells() -> void:
	if _cells:
		var mod_current := current + modifier
		var mod_min := min(current, mod_current)
		var mod_max := max(current, mod_current)

		for i in range(_cells.get_child_count()):
			var cell := _cells.get_child(i) as AnimatedSprite
			cell.visible = i < mod_max

			if i < mod_min:
				cell.frame = _CellState.STAMINA
			elif (i >= mod_min) and (i < current):
				cell.frame = _CellState.DAMAGE
			elif (i >= current) and (i < mod_max):
				cell.frame = _CellState.HEAL
