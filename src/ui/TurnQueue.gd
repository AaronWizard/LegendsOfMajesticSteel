class_name TurnQueue
extends ReferenceRect

const _ANIM_TIME := 0.4

const _ICON_PLAYER := preload("res://assets/graphics/ui/icons/player_turn.png")
const _ICON_ENEMY := preload("res://assets/graphics/ui/icons/enemy_turn.png")
const _ICON_ROUND_MARKER := preload( \
		"res://assets/graphics/ui/icons/round_marker.png" \
)

var _turn_index := 0

onready var _icons := $Icons as Control
onready var _tween := $Tween as Tween

onready var _round_marker := $Icons/RoundMarker as Control


func set_icons(turn_order: Array) -> void:
	_clear()

	# Icons are positioned on the screen in the reverse of their order in the
	# tree.
	# i.e. [N, N-1, ..., 1, 0]; The bottommost icon represents the current turn

	for i in range(turn_order.size() - 1, -1, -1):
		var faction := turn_order[i] as int
		match faction:
			Actor.Faction.PLAYER:
				_add_icon(_ICON_PLAYER)
			Actor.Faction.ENEMY:
				_add_icon(_ICON_ENEMY)
			_:
				assert(false)

	_set_icon_positions()
	rect_size = Vector2.ZERO # Reset size


func next_turn() -> void:
	var first_icon := _icons.get_child(_icons.get_child_count() - 1) as Control
	var dist := 0.0
	var last_icon := _turn_index == (_icons.get_child_count() - 2)

	if last_icon:
		_icons.move_child(_round_marker, 0)
		_icons.move_child(first_icon, 1)
		_queue_anim_icon_move_end(_round_marker, false)
		_queue_anim_icon_move_end(first_icon, true)
		dist = first_icon.rect_size.x + _round_marker.rect_size.x
	else:
		_icons.move_child(first_icon, 0)
		_queue_anim_icon_move_end(first_icon, false)
		dist = first_icon.rect_size.x

	for c in _icons.get_children():
		var icon := c as Control

		var icon_is_first := icon == first_icon
		var icon_is_marker := icon == _round_marker

		if (not last_icon and not icon_is_first) \
				or (last_icon and not (icon_is_first or icon_is_marker)):
			_queue_anim_icon_move_next(icon, dist)

	_turn_index = (_turn_index + 1) % (_icons.get_child_count() - 1)

	# warning-ignore:return_value_discarded
	_tween.start()


func remove_icon(index: int) -> void:
	assert(index >= 0)
	assert(index < (_icons.get_child_count() - 1))

	var real_index: int
	if index < _turn_index:
		real_index = _round_marker.get_index() - index - 1
		assert(real_index < _icons.get_child_count())

		_turn_index -= 1
	else:
		real_index = _icons.get_child_count() - 1 - index + _turn_index

	var old_icon := _icons.get_child(real_index) as Control
	assert(old_icon != _round_marker)
	var dist := old_icon.rect_size.x

	_icons.remove_child(old_icon)
	old_icon.queue_free()

	for i in range(0, real_index):
		var icon := _icons.get_child(i) as Control
		_queue_anim_icon_move_next(icon, dist)
	_queue_anim_shrink(dist)

	# warning-ignore:return_value_discarded
	_tween.start()


func _clear() -> void:
	_icons.remove_child(_round_marker)
	while _icons.get_child_count() > 0:
		var icon := _icons.get_child(0) as Node
		_icons.remove_child(icon)
		icon.queue_free()
	_icons.add_child(_round_marker)

	rect_min_size = _round_marker.rect_size
	_turn_index = 0


func _add_icon(texture: Texture) -> void:
	var icon := TextureRect.new()
	icon.texture = texture
	_icons.add_child(icon)

	rect_min_size.x += icon.rect_size.x
	if rect_min_size.y < icon.rect_size.y:
		rect_min_size.y = icon.rect_size.y


func _set_icon_positions() -> void:
	var x := 0.0
	for i in range(_icons.get_child_count() - 1, -1, -1):
		var icon := _icons.get_child(i) as Control
		icon.rect_position.x = x
		x += icon.rect_size.x


func _queue_anim_icon_move_end(icon: Control, last_icon: bool) -> void:
	var end_pos := Vector2.ZERO
	end_pos.x = rect_min_size.x - icon.rect_size.x
	if last_icon:
		end_pos.x -= _round_marker.rect_size.x
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(icon, "rect_position",
			icon.rect_position, end_pos, _ANIM_TIME)


func _queue_anim_icon_move_next(icon: Control, dist: float) -> void:
	var end_pos := icon.rect_position - Vector2(dist, 0)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(icon, "rect_position",
			icon.rect_position, end_pos, _ANIM_TIME)


func _queue_anim_shrink(dist: float) -> void:
	var end_size := rect_min_size - Vector2(dist, 0)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(self, "rect_min_size",
			rect_min_size, end_size, _ANIM_TIME)
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(self, "rect_size",
			rect_size, end_size, _ANIM_TIME)
