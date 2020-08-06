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
	_resize_panel()


func next_turn() -> void:
	_queue.next_turn()


func remove_icon(index: int) -> void:
	_queue.remove_icon(index)
	_animate_resize()


func _resize_panel() -> void:
	var _queue_size := _queue.rect_size

	_queue_block.rect_min_size = _queue_size
	_queue_block.rect_size = _queue_size

	_scroll.rect_min_size = _queue_size
	_scroll.rect_size = _queue_size

	_scroll_block.rect_min_size = _queue_size
	_scroll_block.rect_size = _queue_size

	_panel.rect_size = Vector2.ZERO

	var width_diff := _panel.rect_size.x - rect_size.x
	if width_diff > 0:
		var bar_height := _scroll.get_h_scrollbar().rect_size.y
		var size_change := Vector2(-width_diff, bar_height)

		_scroll.rect_min_size += size_change
		_scroll.rect_size += size_change

		_scroll_block.rect_min_size += size_change
		_scroll_block.rect_size += size_change

		_panel.rect_size = Vector2.ZERO


func _animate_resize() -> void:
	# warning-ignore:return_value_discarded
	_tween.stop_all()

	var old_size := _panel.rect_size
	_resize_panel()
	var new_size := _panel.rect_size

	_panel.rect_size = old_size
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(_panel, "rect_size",
			old_size, new_size, TurnQueue.ANIM_TIME)
	# warning-ignore:return_value_discarded
	_tween.start()
