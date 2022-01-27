class_name BorderedTurnPanel
extends ReferenceRect

const _BORDER_WIDTH_EXTRA := 6

var turn_panel: TurnPanel setget , get_turn_panel

onready var _turn_panel := $CenterContainer/PanelContainer/ScrollContainer/ \
		TurnPanel as TurnPanel
onready var _scroll := $CenterContainer/PanelContainer/ScrollContainer \
		as ScrollContainer
onready var _tween := $Tween as Tween


func get_turn_panel() -> TurnPanel:
	return _turn_panel


func _new_min_size() -> Vector2:
	var panel := $CenterContainer/PanelContainer/ScrollContainer/TurnPanel \
			as Control
	var result := Vector2.ZERO
	result.x = min(panel.rect_min_size.x + _BORDER_WIDTH_EXTRA, rect_size.x)
	result.y = min(panel.rect_min_size.y, rect_size.y)
	return result


func _resize_border() -> void:
	var border := $CenterContainer/PanelContainer as Control
	var new_min_size := _new_min_size()
	if border.rect_min_size != new_min_size:
		border.rect_min_size = new_min_size
		border.rect_size = Vector2.ZERO


func _scroll_to_turn_slot() -> void:
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
			_scroll, "scroll_horizontal",
			_scroll.scroll_horizontal, _turn_panel.turn_scroll_pos,
			TurnPanel.ANIM_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	# warning-ignore:return_value_discarded
	_tween.start()


func _on_BorderedTurnPanel_resized() -> void:
	_resize_border()


func _on_TurnPanel_minimum_size_changed() -> void:
	_resize_border()


func _on_TurnPanel_turn_advanced() -> void:
	_scroll_to_turn_slot()


func _on_TurnPanel_other_actor_cleared() -> void:
	_scroll_to_turn_slot()
