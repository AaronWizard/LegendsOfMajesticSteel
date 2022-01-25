class_name TurnPanel
extends ReferenceRect

const ANIM_TIME := 0.4

const _FLAT_ICON_BUTTON := preload("res://src/ui/FlatIconButton.tscn")

onready var _actors := $Actors as Control
onready var _current_turn_border := $CurrentTurnBorder as Control
onready var _tween := $Tween as Tween

var _turn_index := 0


func set_actors(actors: Array) -> void:
	clear()
	for a in actors:
		var actor := a as Actor
		_add_actor_icon(actor)

		_turn_index = 0
	_update_min_size()


func clear() -> void:
	while _actors.get_child_count() > 0:
		var child := _actors.get_child(0) as Control
		_actors.remove_child(child)
		child.queue_free()

		_turn_index = 0
	# warning-ignore:return_value_discarded
	_tween.stop_all()


func next_turn() -> void:
	assert(_actors.get_child_count() > 0)
	_turn_index = (_turn_index + 1) % _actors.get_child_count()

	_queue_icon_position_anims()
	_queue_icon_animation(
		_current_turn_border,
		_current_turn_border.rect_position,
		Vector2(_turn_index * Constants.TILE_SIZE, 0)
	)
	# warning-ignore:return_value_discarded
	_tween.start()
	_update_min_size()


func remove_icon(index: int) -> void:
	var icon := _actors.get_child(index) as Control
	_actors.remove_child(icon)
	icon.queue_free()
	if index < _turn_index:
		_turn_index -= 1


func _add_actor_icon(actor: Actor) -> void:
	var index := _actors.get_child_count()

	var icon := _FLAT_ICON_BUTTON.instance() as Button
	icon.icon = actor.portrait
	# warning-ignore:return_value_discarded
	icon.connect("pressed", self, "_on_actor_icon_pressed", [actor, index])
	_actors.add_child(icon)

	assert(icon.rect_size.x == Constants.TILE_SIZE)
	assert(icon.rect_size.y == Constants.TILE_SIZE)

	icon.rect_position.x = index * Constants.TILE_SIZE
	_actors.rect_size.x += icon.rect_size.x


func _queue_icon_position_anims() -> void:
	for i in _actors.get_children():
		var icon := i as Control
		var real_pos := icon.get_index() * Constants.TILE_SIZE
		if icon.rect_position.x != real_pos:
			_queue_icon_animation(
					icon, icon.rect_position, Vector2(real_pos, 0)
			)


func _queue_icon_animation(icon: Control, start: Vector2, end: Vector2) -> void:
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
		icon, "rect_position", start, end,
		ANIM_TIME, Tween.TRANS_QUART, Tween.EASE_IN_OUT
	)


func _update_min_size() -> void:
	rect_min_size = Vector2(
		_actors.get_child_count() * Constants.TILE_SIZE,
		Constants.TILE_SIZE
	)
	rect_size = Vector2.ZERO # Reset size


func _on_actor_icon_pressed(actor: Actor, index: int) -> void:
	print(actor.name, "; ", index)
