class_name BattleGUI
extends CanvasLayer

signal mouse_dragged(relative)
signal wait_pressed

var buttons_visible := false setget set_buttons_visible

var _can_drag := false

onready var _drag_timer: Timer = $DragTimer
onready var _all_buttons: Node = $Buttons


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_drag_timer.start()
			else:
				_drag_timer.stop()
				_can_drag = false
	elif event is InputEventMouseMotion and _can_drag:
		emit_signal("mouse_dragged", event.relative)


func set_buttons_visible(value: bool) -> void:
	for b in _all_buttons.get_children():
		var button: Button = b
		button.visible = value


func _on_DragTimer_timeout() -> void:
	_can_drag = true


func _on_Wait_pressed() -> void:
	emit_signal("wait_pressed")
