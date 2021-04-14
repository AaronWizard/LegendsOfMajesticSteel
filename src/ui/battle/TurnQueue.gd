class_name TurnQueue
extends ReferenceRect

const ANIM_TIME := 0.4

const _ICON_PLAYER := preload( \
		"res://assets/graphics/ui/icons/turnqueue/player_turn.png")
const _ICON_ENEMY := preload( \
		"res://assets/graphics/ui/icons/turnqueue/enemy_turn.png")

var _ICON_WIDTH := max(
	(_ICON_PLAYER as Texture).get_size().x,
	(_ICON_ENEMY as Texture).get_size().x
)
var _ICON_HEIGHT := max(
	(_ICON_PLAYER as Texture).get_size().y,
	(_ICON_ENEMY as Texture).get_size().y
)

var _turn_index := 0

onready var _icons := $Icons as Control
onready var _turn_cursor := $TurnCursor as Control

onready var _tween := $Tween as Tween


func set_icons(turn_order: Array) -> void:
	clear()

	for f in turn_order:
		var faction := f as int
		_add_icon(faction)

	_update_min_size()
	_turn_cursor.rect_position.x = 0


func next_turn() -> void:
	_turn_index = (_turn_index + 1) % _icons.get_child_count()

	_queue_icon_position_anims()
	_queue_icon_animation(
		_turn_cursor,
		_turn_cursor.rect_position,
		Vector2(_turn_index * _ICON_WIDTH, 0)
	)

	# warning-ignore:return_value_discarded
	_tween.start()


func remove_icon(index: int) -> void:
	var icon := _icons.get_child(index) as Control
	_icons.remove_child(icon)
	icon.queue_free()

	if index < _turn_index:
		_turn_index -= 1

	_update_min_size()


func clear() -> void:
	while _icons.get_child_count() > 0:
		var icon := _icons.get_child(0) as Node
		_icons.remove_child(icon)
		icon.queue_free()
	_turn_index = 0


func _add_icon(faction: int) -> void:
	var texture: Texture
	match faction:
		Actor.Faction.PLAYER:
			texture = _ICON_PLAYER
		Actor.Faction.ENEMY:
			texture = _ICON_ENEMY
		_:
			assert(false)

	var icon := TextureRect.new()
	icon.texture = texture
	_icons.add_child(icon)

	icon.rect_position.x = icon.get_index() * _ICON_WIDTH


func _update_min_size() -> void:
	rect_min_size = Vector2(
		_icons.get_child_count() * _ICON_WIDTH,
		_ICON_HEIGHT
	)
	rect_size = Vector2.ZERO # Reset size


func _queue_icon_position_anims() -> void:
	for i in _icons.get_children():
		var icon := i as Control
		var real_pos := icon.get_index() * _ICON_WIDTH
		if icon.rect_position.x != real_pos:
			_queue_icon_animation(
				icon,
				icon.rect_position,
				Vector2(real_pos, 0)
			)


func _queue_icon_animation(icon: Control, start: Vector2, end: Vector2) -> void:
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
		icon, "rect_position", start, end,
		ANIM_TIME, Tween.TRANS_QUART, Tween.EASE_IN_OUT
	)
