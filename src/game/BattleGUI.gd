class_name BattleGUI
extends CanvasLayer

signal mouse_dragged(relative)
signal mouse_clicked(position)
signal wait_pressed
# warning-ignore:unused_signal
signal ability_pressed(ability)

const MIN_DRAG_SPEED_SQUARED = 8^2

var buttons_visible := false setget set_buttons_visible
var dragging_enabled := false

var current_actor: Actor setget set_current_actor

var _mouse_down := false
var _dragging := false

onready var _all_buttons := $Buttons
onready var _ability_buttons := $Buttons/Abilities


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
			button.connect("pressed", self, "emit_signal",
					["ability_pressed", ability])
			_ability_buttons.add_child(button)
	else:
		while _ability_buttons.get_child_count() > 0:
			var button := _ability_buttons.get_child(0)
			_ability_buttons.remove_child(button)
			button.queue_free()


func _on_Wait_pressed() -> void:
	emit_signal("wait_pressed")
