class_name TurnQueue
extends PanelContainer

const _MARGIN := 1
const _ICON_MOVE_TIME := 0.2

const _ENEMY_TURN_ICON := \
		preload("res://assets/graphics/ui/icons/enemy_turn.png")
const _PLAYER_TURN_ICON := \
		preload("res://assets/graphics/ui/icons/player_turn.png")

onready var _scroll := $ScrollContainer as ScrollContainer

onready var _icons_container := $ScrollContainer/IconsContainer as Control
onready var _icons_margin := $ScrollContainer/IconsContainer/IconsMargin \
		as MarginContainer

onready var _icons := $ScrollContainer/IconsContainer/IconsMargin/Icons \
		as Container

onready var _current_turn_icon := \
		$ScrollContainer/IconsContainer/CurrentTurnIcon as Control
onready var _tween := $Tween as Tween

func _ready():
	_current_turn_icon.margin_left = 0

func set_queue(factions: Array) -> void:
	_clear()

	for f in factions:
		var faction := f as int
		match faction:
			Actor.Faction.PLAYER:
				_add_icon(_PLAYER_TURN_ICON)
			Actor.Faction.ENEMY:
				_add_icon(_ENEMY_TURN_ICON)
			_:
				assert(false)


func next_turn():
	var icon_margin_left := 0

	if _icons.get_child_count() > 1:
		var icon := _icons.get_child(1) as Control
		icon_margin_left = int(icon.margin_left)

	var icon := _icons.get_child(0) as Control
	_icons.remove_child(icon)
	icon.queue_free()

	if icon_margin_left > 0:
		_icons_margin.set("custom_constants/margin_left",
				_MARGIN + icon_margin_left)
		# warning-ignore:return_value_discarded
		_tween.interpolate_property(
				_icons_margin, "custom_constants/margin_left",
				_MARGIN + icon_margin_left, _MARGIN,
				_ICON_MOVE_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
		# warning-ignore:return_value_discarded
		_tween.start()


func remove_icon(index: int) -> void:
	var icon := _icons.get_child(index) as Control
	icon.queue_free()


#	# warning-ignore:return_value_discarded
#	_tween.interpolate_property(icon, "margin_top", 0, icon.rect_size.y, 1)
#	# warning-ignore:return_value_discarded
#	_tween.interpolate_callback(icon, 1, "queue_free")
#	# warning-ignore:return_value_discarded
#	_tween.start()


func _clear():
	for c in _icons.get_children():
		var child := c as Node
		child.queue_free()


func _add_icon(texture: Texture) -> void:
	var icon := TextureRect.new()
	icon.texture = texture
	_icons.add_child(icon)


#func _update_cursor() -> void:
#	if _icons.get_child_count() > 0:
#		var icon := _icons.get_child(_index) as Control
#
#		var old_margin_left := _current_turn_icon.margin_left
#		var new_margin_left := icon.margin_left
#
#		if old_margin_left != new_margin_left:
#			#_scroll.scroll_horizontal = int(new_margin_left)
#
#			# warning-ignore:return_value_discarded
#			_tween.interpolate_property(_current_turn_icon, "margin_left",
#					old_margin_left, new_margin_left,
#					_CURRENT_TURN_ICON_MOVE_TIME,
#					Tween.TRANS_SINE, Tween.EASE_OUT)
#			# warning-ignore:return_value_discarded
#			_tween.start()


func _on_IconsMargin_minimum_size_changed():
	_icons_container.rect_min_size = _icons_margin.rect_size
