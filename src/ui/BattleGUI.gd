class_name BattleGUI
extends CanvasLayer

signal camera_dragged(relative)

signal ability_selected(ability_range)
signal ability_target_placed(target_cell, aoe)
signal ability_cleared

signal move_started(target_cell)
signal ability_started(ability, target_cell)
signal wait_started


const _MIN_DRAG_SPEED_SQUARED := 24^2

var buttons_visible := false setget set_buttons_visible
var dragging_enabled := false

var current_map: Map = null
var current_actor: Actor = null setget set_current_actor

var _mouse_down := false
var _dragging := false

var _current_ability: Ability
var _ability_targetting: Ability.TargettingData

var _have_ability_target := false
var _current_ability_target: Vector2

onready var _all_buttons: Container = $Buttons as Container
onready var _ability_buttons: Container = $Buttons/Abilities as Container

onready var _wait_button: Button = $Buttons/Wait as Button
onready var _ability_cancel_button: Button = $Buttons/AbilityCancel as Button


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouseEvent: InputEventMouseButton = event
		if mouseEvent.button_index == BUTTON_LEFT:
			if not mouseEvent.pressed and _mouse_down and not _dragging:
				_on_mouse_clicked()
			_mouse_down = mouseEvent.pressed
	elif event is InputEventMouseMotion:
		var mouseEvent: InputEventMouseMotion = event
		_dragging = dragging_enabled and _mouse_down and \
				(mouseEvent.speed.length_squared() >= _MIN_DRAG_SPEED_SQUARED)
		if _dragging:
			emit_signal("camera_dragged", mouseEvent.relative)


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
	_current_ability = value
	_have_ability_target = false

	if _current_ability:
		_ability_targetting = _current_ability.get_targetting_data(
				current_actor, current_map)

		_ability_buttons.visible = false
		_wait_button.visible = false
		_ability_cancel_button.visible = true
		emit_signal("ability_selected", _ability_targetting.target_range)
	else:
		_ability_targetting = null

		_ability_buttons.visible = true
		_wait_button.visible = true
		_ability_cancel_button.visible = false
		emit_signal("ability_cleared")


func _on_mouse_clicked() -> void:
	var target_cell := current_map.get_mouse_cell()
	if _current_ability and (target_cell in _ability_targetting.valid_targets):
		_click_for_ability_target(target_cell)
	elif not _current_ability:
		emit_signal("move_started", target_cell)


func _click_for_ability_target(target_cell: Vector2) -> void:
	# Click target twice to start action
	if _have_ability_target and (_current_ability_target == target_cell):
		# Clear ability from GUI
		var ability := _current_ability
		set_current_ability(null)
		# Start ability
		emit_signal("ability_started", ability, target_cell)
	else:
		_have_ability_target = true
		_current_ability_target = target_cell
		var aoe := _current_ability.get_aoe(
				current_actor, current_map, target_cell)
		emit_signal("ability_target_placed", target_cell, aoe)


func _on_ability_pressed(ability: Ability) -> void:
	set_current_ability(ability)


func _on_AbilityCancel_pressed() -> void:
	set_current_ability(null)


func _on_Wait_pressed() -> void:
	emit_signal("wait_started")
