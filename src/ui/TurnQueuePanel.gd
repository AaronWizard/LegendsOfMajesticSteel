class_name TurnQueuePanel
extends ReferenceRect

const _ICON_PLAYER := preload("res://assets/graphics/ui/icons/player_turn.png")
const _ICON_ENEMY := preload("res://assets/graphics/ui/icons/enemy_turn.png")

onready var _panel := $Panel as Control

onready var _scroll_block := $Panel/ScrollBlock as Control
onready var _scroll := $Panel/ScrollBlock/Scroll as ScrollContainer

onready var _queue_block := $Panel/ScrollBlock/Scroll/QueueBlock as Control
onready var _queue := $Panel/ScrollBlock/Scroll/QueueBlock/TurnQueue \
		as TurnQueue

onready var _tween := $Tween as Tween


func set_queue(turn_order: Array) -> void:
	_queue.set_icons(turn_order)
	_do_resize()


func next_turn() -> void:
	_queue.next_turn()


func remove_icon(index: int) -> void:
	_queue.remove_icon(index)
	_do_resize()


func _do_resize() -> void:
	_resize_icons_block()
	var old_panel_size := _panel.rect_size
	_resize_panel()
	_queue_animate_panel_size_change(old_panel_size)
	# warning-ignore:return_value_discarded
	_tween.start()


func _resize_icons_block() -> void:
	_queue_block.rect_min_size = _queue.rect_size
	_queue_block.rect_size = Vector2.ZERO


func _resize_panel() -> void:
	_scroll.scroll_horizontal_enabled = false

	_scroll.rect_min_size = _queue.rect_size
	_scroll.rect_size = Vector2.ZERO # Reset scroll size

	_scroll_block.rect_min_size = _scroll.rect_size
	_panel.rect_size = Vector2.ZERO # Reset panel size

	var diff := _panel.rect_size.x - rect_size.x
	if diff > 0:
		_scroll.scroll_horizontal_enabled = true
		_scroll.rect_min_size.x -= diff
		_scroll.rect_size = Vector2.ZERO # Reset scroll size with new width

		_scroll_block.rect_min_size.x -= diff
		_scroll_block.rect_min_size.y += _scroll.get_h_scrollbar().rect_size.y

		_panel.rect_size = Vector2.ZERO # Reset panel size again
	else:
		_scroll.scroll_horizontal_enabled = false

	# The scroll block's min size was only needed to figure out the panel's size
	# This also needs to be zero so the panel's size can be animated
	_scroll_block.rect_min_size = Vector2.ZERO


func _queue_animate_panel_size_change(old_panel_size: Vector2) -> void:
	var new_panel_size := _panel.rect_size

	_panel.rect_size = old_panel_size
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(_panel, "rect_size",
			old_panel_size, new_panel_size, TurnQueue.ANIM_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
