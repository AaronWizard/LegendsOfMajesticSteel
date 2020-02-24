class_name BattleGUI
extends CanvasLayer

signal mouse_dragged(relative)
signal mouse_clicked(position)
signal wait_pressed

const MIN_DRAG_SPEED_SQUARED = 8^2

var buttons_visible := false setget set_buttons_visible
var dragging_enabled := false

var _mouse_down := false
var _dragging := false

onready var _all_buttons: Node = $Buttons


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if not event.pressed and _mouse_down and not _dragging:
				emit_signal("mouse_clicked", event.position)
			_mouse_down = event.pressed
	elif event is InputEventMouseMotion:
		_dragging = dragging_enabled and _mouse_down \
				and (event.speed.length_squared() >= MIN_DRAG_SPEED_SQUARED)
		if _dragging:
			emit_signal("mouse_dragged", event.relative)


func set_buttons_visible(value: bool) -> void:
	for b in _all_buttons.get_children():
		var button: Button = b
		button.visible = value


func _on_Wait_pressed() -> void:
	emit_signal("wait_pressed")
