class_name StaminaBar
extends Node2D

signal animation_finished

var current := Constants.MAX_STAMINA setget set_current
var modifier := 0 setget set_modifier

onready var _cells := $Cells as Node

onready var _damage := $Damage as Node2D
onready var _healing := $Healing as Node2D

onready var _cell_change_delay := $CellChangeDelay as Timer
onready var _cell_change := $CellChange as Timer


func set_current(value: int) -> void:
	current = int(clamp(value, 0, Constants.MAX_STAMINA))
	_update_cells()


func set_modifier(value: int) -> void:
	modifier = int(clamp(value, -current, Constants.MAX_STAMINA - current))
	_update_cells()


func animate_change(delta: int) -> void:
	if delta != 0:
		set_modifier(modifier + delta)
		if modifier != 0:
			_cell_change.stop()
			_cell_change_delay.start()


func _update_cells() -> void:
	if _cells:
		for c in _cells.get_children():
			var cell := c as Node2D
			cell.visible = cell.get_index() < current

	if _damage:
		if modifier < 0:
			assert(current + modifier >= 0)
			var min_value := current + modifier
			var max_value := current
			_update_modifier_cells(_damage, min_value, max_value)
		else:
			_damage.visible = false

	if _healing:
		if modifier > 0:
			assert(current + modifier <= Constants.MAX_STAMINA)
			var min_value := current
			var max_value := current + modifier
			_update_modifier_cells(_healing, min_value, max_value)
		else:
			_healing.visible = false


func _update_modifier_cells(modifier_cells: Node2D,
		min_value: int, max_value: int) -> void:
	modifier_cells.visible = true

	for c in modifier_cells.get_children():
		var cell := c as Node2D
		var index := cell.get_index() + 1
		cell.visible = (index > min_value) and (index <= max_value)


func _on_CellChangeDelay_timeout() -> void:
	assert(modifier != 0)
	assert((current >= 0) && (current <= Constants.MAX_STAMINA))
	_cell_change.start()


func _on_CellChange_timeout() -> void:
	assert(modifier != 0)
	assert((current >= 0) && (current <= Constants.MAX_STAMINA))

	var delta := int(sign(modifier))
	set_modifier(modifier - delta)
	set_current(current + delta)

	if modifier == 0:
		_cell_change.stop()
		emit_signal("animation_finished")
