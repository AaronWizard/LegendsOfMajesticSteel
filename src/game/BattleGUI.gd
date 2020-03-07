class_name BattleGUI
extends CanvasLayer

signal mouse_dragged(relative)
signal mouse_clicked(position)
signal wait_pressed
signal ability_pressed(ability)
signal ability_cleared

const MIN_DRAG_SPEED_SQUARED = 8^2

var buttons_visible := false setget set_buttons_visible
var dragging_enabled := false

var current_actor: Actor setget set_current_actor
var current_ability: Ability setget set_current_ability

var _mouse_down := false
var _dragging := false

onready var _all_buttons: Container = $Buttons
onready var _ability_buttons: Container = $Buttons/Abilities

onready var _wait_button: Button = $Buttons/Wait
onready var _ability_cancel_button: Button = $Buttons/AbilityCancel


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
	_all_buttons.visible = value


func set_current_actor(value: Actor) -> void:
	current_actor = value
	if current_actor:
		for a in current_actor.get_abilities():
			var ability: Ability = a
			var button := Button.new()
			button.text = ability.name
			# warning-ignore:return_value_discarded
			button.connect("pressed", self, "_on_ability_pressed", [ability])
			_ability_buttons.add_child(button)
	else:
		while _ability_buttons.get_child_count() > 0:
			var button := _ability_buttons.get_child(0)
			_ability_buttons.remove_child(button)
			button.disconnect("pressed", self, "_on_ability_pressed")
			button.queue_free()


func set_current_ability(value: Ability) -> void:
	current_ability = value
	if current_ability:
		_ability_buttons.visible = false
		_wait_button.visible = false
		_ability_cancel_button.visible = true
	else:
		_ability_buttons.visible = true
		_wait_button.visible = true
		_ability_cancel_button.visible = false


func _on_ability_pressed(ability: Ability) -> void:
	set_current_ability(ability)
	emit_signal("ability_pressed", ability)


func _on_Wait_pressed() -> void:
	emit_signal("wait_pressed")


func _on_AbilityCancel_pressed() -> void:
	set_current_ability(null)
	emit_signal("ability_cleared")
