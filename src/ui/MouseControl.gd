class_name MouseControl
extends Node

signal click(position)
signal drag(relative)

const _MIN_DRAG_DISTANCE_SQRD := 3 * 3

export var dragging_enabled := false

var _mouse_down := false
var _first_mouse_down_pos: Vector2

var _dragging := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_mouse_click(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_mouse_move(event as InputEventMouseMotion)


func _mouse_click(event: InputEventMouseButton) -> void:
	if event.button_index == BUTTON_LEFT:
		if event.pressed:
			_first_mouse_down_pos = event.position
			_mouse_down = true
		else:
			if _mouse_down and not _dragging:
				emit_signal("click", event.position)
			_mouse_down = false
			_dragging = false


func _mouse_move(event: InputEventMouseMotion) -> void:
	if dragging_enabled and _mouse_down:
		if not _dragging:
			_dragging = event.position.distance_squared_to( \
					_first_mouse_down_pos) > _MIN_DRAG_DISTANCE_SQRD
		if _dragging:
			emit_signal("drag", event.relative)
